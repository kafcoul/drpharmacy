<?php

namespace App\Console\Commands;

use App\Models\User;
use Illuminate\Console\Command;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Validator;

class MakeAdminUser extends Command
{
    /**
     * The name and signature of the console command.
     *
     * @var string
     */
    protected $signature = 'drpharma:make-admin';

    /**
     * The console command description.
     *
     * @var string
     */
    protected $description = 'Create a new admin user';

    /**
     * Execute the console command.
     */
    public function handle()
    {
        $this->info('Creating a new Admin user for DR-PHARMA');

        $name = $this->ask('Name', 'Admin User');
        
        $email = $this->ask('Email');
        while (!$this->validateEmail($email)) {
            $this->error('Invalid email or email already exists.');
            $email = $this->ask('Email');
        }

        $phone = $this->ask('Phone Number (optional)');

        $password = $this->secret('Password');
        $confirmPassword = $this->secret('Confirm Password');

        while ($password !== $confirmPassword || strlen($password) < 8) {
            if (strlen($password) < 8) {
                $this->error('Password must be at least 8 characters.');
            } else {
                $this->error('Passwords do not match.');
            }
            $password = $this->secret('Password');
            $confirmPassword = $this->secret('Confirm Password');
        }

        $user = User::create([
            'name' => $name,
            'email' => $email,
            'password' => Hash::make($password),
            'phone' => $phone,
            'role' => 'admin',
            'email_verified_at' => now(),
            'phone_verified_at' => now(),
        ]);

        $this->info("Admin user '{$user->name}' ({$user->email}) created successfully!");
        
        return Command::SUCCESS;
    }

    protected function validateEmail($email)
    {
        $validator = Validator::make(['email' => $email], [
            'email' => 'required|email|unique:users,email',
        ]);

        return !$validator->fails();
    }
}
