<?php

namespace Tests\Unit;

use App\Models\Batch;
use App\Models\Campus;
use App\Models\Department;
use App\Models\Faculty;
use App\Models\Section;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Tests\TestCase;

class InstitutionalTopologyUnitTest extends TestCase
{
    /**
     * Test Campus model fillable attributes, casting, and relations.
     */
    public function test_campus_model_attributes_and_relationships(): void
    {
        $campus = new Campus();

        // Fillable attributes
        $this->assertEquals(['name', 'code', 'is_active'], $campus->getFillable());

        // Casts
        $this->assertTrue($campus->hasCast('is_active', 'boolean'));

        // Relation: Campus hasMany Faculties
        $relation = $campus->faculties();
        $this->assertInstanceOf(HasMany::class, $relation);
        $this->assertInstanceOf(Faculty::class, $relation->getRelated());
        $this->assertEquals('campus_id', $relation->getForeignKeyName());
    }

    /**
     * Test Faculty model fillable attributes, casting, and relations.
     */
    public function test_faculty_model_attributes_and_relationships(): void
    {
        $faculty = new Faculty();

        // Fillable attributes
        $this->assertEquals(['campus_id', 'name', 'code', 'is_active'], $faculty->getFillable());

        // Casts
        $this->assertTrue($faculty->hasCast('is_active', 'boolean'));

        // Relation: Faculty belongsTo Campus
        $campusRelation = $faculty->campus();
        $this->assertInstanceOf(BelongsTo::class, $campusRelation);
        $this->assertInstanceOf(Campus::class, $campusRelation->getRelated());
        $this->assertEquals('campus_id', $campusRelation->getForeignKeyName());

        // Relation: Faculty hasMany Departments
        $deptRelation = $faculty->departments();
        $this->assertInstanceOf(HasMany::class, $deptRelation);
        $this->assertInstanceOf(Department::class, $deptRelation->getRelated());
        $this->assertEquals('faculty_id', $deptRelation->getForeignKeyName());
    }

    /**
     * Test Department model topology fillable attributes, casting, and relations.
     */
    public function test_department_model_topology_attributes_and_relationships(): void
    {
        $department = new Department();

        // Fillable includes faculty_id
        $this->assertContains('faculty_id', $department->getFillable());
        $this->assertContains('name', $department->getFillable());
        $this->assertContains('code', $department->getFillable());

        // Casts
        $this->assertTrue($department->hasCast('is_active', 'boolean'));

        // Relation: Department belongsTo Faculty
        $facultyRelation = $department->faculty();
        $this->assertInstanceOf(BelongsTo::class, $facultyRelation);
        $this->assertInstanceOf(Faculty::class, $facultyRelation->getRelated());
        $this->assertEquals('faculty_id', $facultyRelation->getForeignKeyName());

        // Relation: Department hasMany Batches
        $batchesRelation = $department->batches();
        $this->assertInstanceOf(HasMany::class, $batchesRelation);
        $this->assertInstanceOf(Batch::class, $batchesRelation->getRelated());
        $this->assertEquals('department_id', $batchesRelation->getForeignKeyName());
    }

    /**
     * Test Batch model topology fillable attributes, casting, and relations.
     */
    public function test_batch_model_topology_attributes_and_relationships(): void
    {
        $batch = new Batch();

        // Fillable includes department_id
        $this->assertContains('department_id', $batch->getFillable());
        $this->assertContains('name', $batch->getFillable());
        $this->assertContains('start_year', $batch->getFillable());
        $this->assertContains('end_year', $batch->getFillable());

        // Casts
        $this->assertTrue($batch->hasCast('is_active', 'boolean'));
        $this->assertTrue($batch->hasCast('start_year', 'integer'));
        $this->assertTrue($batch->hasCast('end_year', 'integer'));

        // Relation: Batch belongsTo Department
        $deptRelation = $batch->department();
        $this->assertInstanceOf(BelongsTo::class, $deptRelation);
        $this->assertInstanceOf(Department::class, $deptRelation->getRelated());
        $this->assertEquals('department_id', $deptRelation->getForeignKeyName());

        // Relation: Batch hasMany Sections
        $sectionsRelation = $batch->sections();
        $this->assertInstanceOf(HasMany::class, $sectionsRelation);
        $this->assertInstanceOf(Section::class, $sectionsRelation->getRelated());
    }
}

