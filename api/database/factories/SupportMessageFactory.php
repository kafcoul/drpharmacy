<?php

namespace Database\Factories;

use App\Models\SupportMessage;
use App\Models\SupportTicket;
use App\Models\User;
use Illuminate\Database\Eloquent\Factories\Factory;

class SupportMessageFactory extends Factory
{
    protected $model = SupportMessage::class;

    public function definition(): array
    {
        return [
            'support_ticket_id' => SupportTicket::factory(),
            'user_id' => User::factory(),
            'message' => fake()->paragraph(),
            'is_from_admin' => false,
            'attachments' => null,
            'read_at' => null,
        ];
    }

    public function fromAdmin(): static
    {
        return $this->state(fn (array $attributes) => [
            'is_from_admin' => true,
        ]);
    }

    public function fromUser(): static
    {
        return $this->state(fn (array $attributes) => [
            'is_from_admin' => false,
        ]);
    }

    public function read(): static
    {
        return $this->state(fn (array $attributes) => [
            'read_at' => now(),
        ]);
    }

    public function withAttachments(): static
    {
        return $this->state(fn (array $attributes) => [
            'attachments' => json_encode([
                'images/support/attachment1.jpg',
                'images/support/attachment2.jpg',
            ]),
        ]);
    }
}
