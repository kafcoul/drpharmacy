<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use App\Models\User;
use Illuminate\Support\Facades\Hash;

class ResetPharmacyPasswordSeeder extends Seeder
{
    public function run()
    {
        $user = User::where('email', 'pharmacy@test.com')->first();
        if ($user) {
            $user->password = Hash::make('password');
            $user->save();
            $this->command->info('Password for pharmacy@test.com reset to: password');
        } else {
            $this->command->error('User pharmacy@test.com not found');
        }
    }
}
