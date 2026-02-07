<?php

namespace Tests\Feature\Api\Courier;

use App\Models\User;
use App\Models\Courier;
use App\Models\WalletTransaction;
use App\Services\WalletService;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;
use Mockery;

class WalletControllerTest extends TestCase
{
    use RefreshDatabase;

    protected $user;
    protected $courier;

    protected function setUp(): void
    {
        parent::setUp();

        $this->user = User::factory()->create(['role' => 'courier']);
        $this->courier = Courier::factory()->create([
            'user_id' => $this->user->id,
            'status' => 'available',
        ]);
    }

    /** @test */
    public function courier_can_get_wallet_balance()
    {
        $response = $this->actingAs($this->user, 'sanctum')
            ->getJson('/api/courier/wallet');

        $response->assertOk()
            ->assertJsonStructure([
                'status',
                'data' => [
                    'balance',
                    'currency',
                    'pending_payouts',
                    'available_balance',
                    'can_deliver',
                    'commission_amount',
                    'total_topups',
                    'total_earnings',
                    'total_commissions',
                    'deliveries_count',
                    'transactions',
                ],
            ]);
    }

    /** @test */
    public function courier_can_topup_wallet()
    {
        $this->mock(WalletService::class, function ($mock) {
            $mock->shouldReceive('topUp')
                ->once()
                ->andReturn((object)[
                    'id' => 1,
                    'reference' => 'TOP-123',
                    'amount' => 5000,
                    'balance_after' => 5000,
                ]);
            $mock->shouldReceive('getBalance')
                ->andReturn([
                    'balance' => 5000,
                    'currency' => 'XOF',
                    'pending_withdrawals' => 0,
                    'available_balance' => 5000,
                    'can_deliver' => true,
                    'commission_amount' => 200,
                ]);
        });

        $response = $this->actingAs($this->user, 'sanctum')
            ->postJson('/api/courier/wallet/topup', [
                'amount' => 5000,
                'payment_method' => 'orange_money',
                'payment_reference' => 'PAY-123',
            ]);

        $response->assertOk()
            ->assertJsonPath('status', 'success')
            ->assertJsonPath('message', 'Rechargement effectué avec succès')
            ->assertJsonStructure([
                'status',
                'message',
                'data' => [
                    'transaction' => ['id', 'reference', 'amount', 'balance_after'],
                    'wallet',
                ],
            ]);
    }

    /** @test */
    public function topup_validates_minimum_amount()
    {
        $response = $this->actingAs($this->user, 'sanctum')
            ->postJson('/api/courier/wallet/topup', [
                'amount' => 100, // Less than minimum
                'payment_method' => 'orange_money',
            ]);

        $response->assertStatus(422)
            ->assertJsonValidationErrors(['amount']);
    }

    /** @test */
    public function topup_validates_maximum_amount()
    {
        $response = $this->actingAs($this->user, 'sanctum')
            ->postJson('/api/courier/wallet/topup', [
                'amount' => 1000000, // More than maximum
                'payment_method' => 'orange_money',
            ]);

        $response->assertStatus(422)
            ->assertJsonValidationErrors(['amount']);
    }

    /** @test */
    public function topup_validates_payment_method()
    {
        $response = $this->actingAs($this->user, 'sanctum')
            ->postJson('/api/courier/wallet/topup', [
                'amount' => 5000,
                'payment_method' => 'invalid_method',
            ]);

        $response->assertStatus(422)
            ->assertJsonValidationErrors(['payment_method']);
    }

    /** @test */
    public function courier_can_request_withdrawal()
    {
        $this->mock(WalletService::class, function ($mock) {
            $mock->shouldReceive('requestWithdrawal')
                ->once()
                ->andReturn((object)[
                    'id' => 1,
                    'reference' => 'WD-123',
                    'amount' => 3000,
                    'status' => 'pending',
                ]);
            $mock->shouldReceive('getBalance')
                ->andReturn([
                    'balance' => 2000,
                    'currency' => 'XOF',
                    'pending_withdrawals' => 3000,
                    'available_balance' => 2000,
                    'can_deliver' => true,
                    'commission_amount' => 200,
                ]);
        });

        $response = $this->actingAs($this->user, 'sanctum')
            ->postJson('/api/courier/wallet/withdraw', [
                'amount' => 3000,
                'payment_method' => 'orange_money',
                'phone_number' => '0787654321',
            ]);

        $response->assertOk()
            ->assertJsonPath('status', 'success');
    }

    /** @test */
    public function withdrawal_validates_minimum_amount()
    {
        $response = $this->actingAs($this->user, 'sanctum')
            ->postJson('/api/courier/wallet/withdraw', [
                'amount' => 100,
                'payment_method' => 'orange_money',
                'phone_number' => '0787654321',
            ]);

        $response->assertStatus(422)
            ->assertJsonValidationErrors(['amount']);
    }

    /** @test */
    public function withdrawal_validates_phone_number_format()
    {
        $response = $this->actingAs($this->user, 'sanctum')
            ->postJson('/api/courier/wallet/withdraw', [
                'amount' => 3000,
                'payment_method' => 'orange_money',
                'phone_number' => 'invalid',
            ]);

        $response->assertStatus(422)
            ->assertJsonValidationErrors(['phone_number']);
    }

    /** @test */
    public function courier_can_get_transaction_history()
    {
        // Create some transactions
        WalletTransaction::factory()->count(5)->create([
            'courier_id' => $this->courier->id,
            'type' => 'topup',
            'amount' => 1000,
            'status' => 'completed',
        ]);

        $response = $this->actingAs($this->user, 'sanctum')
            ->getJson('/api/courier/wallet/transactions');

        $response->assertOk()
            ->assertJsonStructure([
                'status',
                'data' => [
                    'transactions' => [
                        '*' => ['id', 'amount', 'type', 'description', 'date'],
                    ],
                ],
            ]);
    }

    /** @test */
    public function courier_can_view_transaction_detail()
    {
        $transaction = WalletTransaction::factory()->create([
            'courier_id' => $this->courier->id,
            'type' => 'topup',
            'amount' => 5000,
            'status' => 'completed',
            'reference' => 'TOP-DETAIL-123',
        ]);

        $response = $this->actingAs($this->user, 'sanctum')
            ->getJson("/api/courier/wallet/transactions/{$transaction->id}");

        $response->assertOk();
    }

    /** @test */
    public function non_courier_cannot_access_wallet()
    {
        $customer = User::factory()->create(['role' => 'customer']);

        $response = $this->actingAs($customer, 'sanctum')
            ->getJson('/api/courier/wallet');

        $response->assertStatus(403);
    }

    /** @test */
    public function unauthenticated_user_cannot_access_wallet()
    {
        $response = $this->getJson('/api/courier/wallet');

        $response->assertUnauthorized();
    }

    /** @test */
    public function wallet_shows_correct_statistics()
    {
        $this->mock(WalletService::class, function ($mock) {
            $mock->shouldReceive('getBalance')
                ->andReturn([
                    'balance' => 15000,
                    'currency' => 'XOF',
                    'pending_withdrawals' => 5000,
                    'available_balance' => 10000,
                    'can_deliver' => true,
                    'commission_amount' => 200,
                ]);
            $mock->shouldReceive('getStatistics')
                ->andReturn([
                    'total_topups' => 50000,
                    'total_delivery_earnings' => 30000,
                    'total_commissions' => 5000,
                    'deliveries_count' => 25,
                ]);
            $mock->shouldReceive('getTransactionHistory')
                ->andReturn(collect([]));
        });

        $response = $this->actingAs($this->user, 'sanctum')
            ->getJson('/api/courier/wallet');

        $response->assertOk()
            ->assertJsonPath('data.balance', 15000)
            ->assertJsonPath('data.total_topups', 50000)
            ->assertJsonPath('data.total_earnings', 30000)
            ->assertJsonPath('data.deliveries_count', 25);
    }
}
