<?php

namespace Tests\Feature;

use App\Models\Batch;
use App\Models\Campus;
use App\Models\Department;
use App\Models\Faculty;
use App\Models\Section;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\Schema;
use Tests\TestCase;

class InstitutionalTopologyIntegrationTest extends TestCase
{
    use RefreshDatabase;

    /**
     * Test database schema contains all required Prompt 1 topology tables and columns.
     */
    public function test_institutional_topology_schema_is_correct(): void
    {
        // Campuses table and columns
        $this->assertTrue(Schema::hasTable('campuses'), 'Table "campuses" must exist.');
        $this->assertTrue(Schema::hasColumns('campuses', ['id', 'name', 'code', 'is_active', 'created_at', 'updated_at']));

        // Faculties table and columns
        $this->assertTrue(Schema::hasTable('faculties'), 'Table "faculties" must exist.');
        $this->assertTrue(Schema::hasColumns('faculties', ['id', 'campus_id', 'name', 'code', 'is_active', 'created_at', 'updated_at']));

        // Departments foreign key column
        $this->assertTrue(Schema::hasTable('departments'), 'Table "departments" must exist.');
        $this->assertTrue(Schema::hasColumn('departments', 'faculty_id'), 'Column "departments.faculty_id" must exist.');

        // Batches foreign key column
        $this->assertTrue(Schema::hasTable('batches'), 'Table "batches" must exist.');
        $this->assertTrue(Schema::hasColumn('batches', 'department_id'), 'Column "batches.department_id" must exist.');
    }

    /**
     * Test migration auto-seeds initial default campus and faculty for zero-downtime compatibility.
     */
    public function test_default_campus_and_faculty_seeded_by_migration(): void
    {
        $mainCampus = Campus::where('code', 'MAIN')->first();
        $this->assertNotNull($mainCampus, 'Default MAIN campus must be seeded.');
        $this->assertEquals('Main Campus', $mainCampus->name);

        $feceFaculty = Faculty::where('code', 'FECE')->first();
        $this->assertNotNull($feceFaculty, 'Default FECE faculty must be seeded.');
        $this->assertEquals($mainCampus->id, $feceFaculty->campus_id);
    }

    /**
     * Test full institutional hierarchy creation and nested eager loading traversal.
     * Campus -> Faculty -> Department -> Batch -> Section
     */
    public function test_full_hierarchy_persistence_and_eager_loading(): void
    {
        $campus = Campus::create([
            'name' => 'Islamabad Campus',
            'code' => 'ISB',
            'is_active' => true,
        ]);

        $faculty = Faculty::create([
            'campus_id' => $campus->id,
            'name' => 'Faculty of Engineering & Technology',
            'code' => 'FET',
            'is_active' => true,
        ]);

        $department = Department::create([
            'faculty_id' => $faculty->id,
            'name' => 'Software Engineering',
            'code' => 'SE',
            'description' => 'Department of Software Engineering',
            'is_active' => true,
        ]);

        $batch = Batch::create([
            'department_id' => $department->id,
            'name' => 'Batch 2024-2028',
            'start_year' => 2024,
            'end_year' => 2028,
            'is_active' => true,
        ]);

        $section = Section::create([
            'batch_id' => $batch->id,
            'name' => 'Section A',
            'is_active' => true,
        ]);

        // Eager load downward through the entire graph
        $loadedCampus = Campus::with('faculties.departments.batches.sections')->find($campus->id);

        $this->assertNotNull($loadedCampus);
        $this->assertCount(1, $loadedCampus->faculties);
        $this->assertEquals('FET', $loadedCampus->faculties->first()->code);

        $loadedFaculty = $loadedCampus->faculties->first();
        $this->assertCount(1, $loadedFaculty->departments);
        $this->assertEquals('SE', $loadedFaculty->departments->first()->code);

        $loadedDept = $loadedFaculty->departments->first();
        $this->assertCount(1, $loadedDept->batches);
        $this->assertEquals('Batch 2024-2028', $loadedDept->batches->first()->name);

        $loadedBatch = $loadedDept->batches->first();
        $this->assertCount(1, $loadedBatch->sections);
        $this->assertEquals('Section A', $loadedBatch->sections->first()->name);

        // Traverse backward through the inverse relationships
        $this->assertEquals($batch->id, $section->batch->id);
        $this->assertEquals($department->id, $section->batch->department->id);
        $this->assertEquals($faculty->id, $section->batch->department->faculty->id);
        $this->assertEquals($campus->id, $section->batch->department->faculty->campus->id);
    }

    /**
     * Test multi-department batch isolation to ensure clean university-wide expansion.
     */
    public function test_multi_department_batch_isolation(): void
    {
        $faculty = Faculty::first();

        $csDept = Department::create([
            'faculty_id' => $faculty->id,
            'name' => 'Computer Science',
            'code' => 'CS',
            'is_active' => true,
        ]);

        $eeDept = Department::create([
            'faculty_id' => $faculty->id,
            'name' => 'Electrical Engineering',
            'code' => 'EE',
            'is_active' => true,
        ]);

        $csBatch2023 = Batch::create([
            'department_id' => $csDept->id,
            'name' => 'CS-2023',
            'start_year' => 2023,
            'end_year' => 2027,
            'is_active' => true,
        ]);

        $csBatch2024 = Batch::create([
            'department_id' => $csDept->id,
            'name' => 'CS-2024',
            'start_year' => 2024,
            'end_year' => 2028,
            'is_active' => true,
        ]);

        $eeBatch2023 = Batch::create([
            'department_id' => $eeDept->id,
            'name' => 'EE-2023',
            'start_year' => 2023,
            'end_year' => 2027,
            'is_active' => true,
        ]);

        // CS Department must only return CS batches
        $csBatches = $csDept->batches()->pluck('name')->toArray();
        $this->assertCount(2, $csBatches);
        $this->assertContains('CS-2023', $csBatches);
        $this->assertContains('CS-2024', $csBatches);
        $this->assertNotContains('EE-2023', $csBatches);

        // EE Department must only return EE batches
        $eeBatches = $eeDept->batches()->pluck('name')->toArray();
        $this->assertCount(1, $eeBatches);
        $this->assertContains('EE-2023', $eeBatches);
        $this->assertNotContains('CS-2023', $eeBatches);
    }

    /**
     * Test relational cascade behaviors:
     * - Deleting campus cascades to its faculties
     * - Deleting faculty sets department faculty_id to null
     * - Deleting department cascades to its batches
     */
    public function test_topology_cascading_and_foreign_key_integrity(): void
    {
        $campus = Campus::create([
            'name' => 'Mardan Satellite Campus',
            'code' => 'MSC',
            'is_active' => true,
        ]);

        $faculty = Faculty::create([
            'campus_id' => $campus->id,
            'name' => 'Faculty of Applied Sciences',
            'code' => 'FAS',
            'is_active' => true,
        ]);

        $department = Department::create([
            'faculty_id' => $faculty->id,
            'name' => 'Mathematics',
            'code' => 'MATH',
            'is_active' => true,
        ]);

        $batch = Batch::create([
            'department_id' => $department->id,
            'name' => 'Math-2024',
            'start_year' => 2024,
            'end_year' => 2028,
            'is_active' => true,
        ]);

        // 1. Deleting department deletes its batches (onDelete('cascade'))
        $department->forceDelete();
        $this->assertDatabaseMissing('batches', ['id' => $batch->id]);

        // 2. Re-create a department for faculty deletion test
        $department2 = Department::create([
            'faculty_id' => $faculty->id,
            'name' => 'Physics',
            'code' => 'PHY',
            'is_active' => true,
        ]);

        // Deleting faculty sets department faculty_id to null (onDelete('set null'))
        $faculty->delete();
        $this->assertDatabaseMissing('faculties', ['id' => $faculty->id]);
        $department2->refresh();
        $this->assertNull($department2->faculty_id, 'Department faculty_id must be set to null when faculty is deleted.');

        // 3. Deleting campus cascades to faculties (onDelete('cascade'))
        $campus2 = Campus::create([
            'name' => 'Swabi Campus',
            'code' => 'SWB',
            'is_active' => true,
        ]);

        $faculty2 = Faculty::create([
            'campus_id' => $campus2->id,
            'name' => 'Faculty of Life Sciences',
            'code' => 'FLS',
            'is_active' => true,
        ]);

        $campus2->delete();
        $this->assertDatabaseMissing('faculties', ['id' => $faculty2->id]);
    }

    /**
     * Test active scopes and boolean casting on topology models.
     */
    public function test_active_state_handling(): void
    {
        $campusActive = Campus::create(['name' => 'Active Campus', 'code' => 'ACT', 'is_active' => true]);
        $campusInactive = Campus::create(['name' => 'Inactive Campus', 'code' => 'INACT', 'is_active' => false]);

        $this->assertTrue($campusActive->is_active);
        $this->assertFalse($campusInactive->is_active);

        $dept = Department::create([
            'name' => 'Civil Engineering',
            'code' => 'CE',
            'is_active' => false,
        ]);

        $activeDepts = Department::active()->get();
        $this->assertFalse($activeDepts->contains('id', $dept->id));
    }
}

