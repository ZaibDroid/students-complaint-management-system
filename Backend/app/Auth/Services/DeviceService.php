<?php

namespace App\Auth\Services;

use App\Models\User;
use App\Models\UserDevice;
use Illuminate\Http\Request;

class DeviceService
{
    /**
     * Register or update a device for a user.
     */
    public function registerOrUpdateDevice(User $user, Request $request, string $refreshTokenHash, \Illuminate\Support\Carbon $refreshTokenExpiresAt): UserDevice
    {
        // Enforce maximum 5 active devices limit
        $activeDevicesCount = $user->devices()->whereNull('revoked_at')->count();
        if ($activeDevicesCount >= 5) {
            // Revoke the oldest used active device
            $oldestDevice = $user->devices()->whereNull('revoked_at')->orderBy('last_used_at', 'asc')->first();
            if ($oldestDevice) {
                $this->revokeDevice($oldestDevice);
                event(new \App\Auth\Events\DeviceRevoked($oldestDevice));
            }
        }

        $deviceId = $request->input('device_id');
        
        $device = UserDevice::firstOrNew([
            'user_id' => $user->id,
            'device_id' => $deviceId,
        ]);

        $device->fill([
            'device_name' => $request->input('device_name', $device->device_name),
            'platform' => $request->input('platform', $device->platform),
            'app_version' => $request->input('app_version', $device->app_version),
            'os_version' => $request->input('os_version', $device->os_version),
            'push_token' => $request->input('push_token', $device->push_token),
            'ip_address' => $request->ip(),
            'refresh_token_hash' => $refreshTokenHash,
            'refresh_token_expires_at' => $refreshTokenExpiresAt,
            'last_used_at' => now(),
            'last_login_at' => now(),
            'revoked_at' => null, // Un-revoke if it was previously revoked and they log back in
        ]);

        $device->save();

        return $device;
    }

    /**
     * Update the last used timestamp for a given token hash.
     */
    public function recordUsage(string $refreshTokenHash, string $ipAddress): ?UserDevice
    {
        $device = UserDevice::where('refresh_token_hash', $refreshTokenHash)->first();
        if ($device) {
            $device->update([
                'last_used_at' => now(),
                'ip_address' => $ipAddress,
            ]);
        }
        return $device;
    }

    /**
     * Revoke a specific device.
     */
    public function revokeDevice(UserDevice $device): void
    {
        $device->update([
            'refresh_token_hash' => null,
            'refresh_token_expires_at' => null,
            'revoked_at' => now(),
        ]);
    }

    /**
     * Revoke all devices for a user except the current one.
     */
    public function revokeOtherDevices(User $user, UserDevice $currentDevice): void
    {
        $user->devices()
             ->where('id', '!=', $currentDevice->id)
             ->update([
                 'refresh_token_hash' => null,
                 'refresh_token_expires_at' => null,
                 'revoked_at' => now(),
             ]);
    }
}
