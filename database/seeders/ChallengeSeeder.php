<?php

namespace Database\Seeders;

use App\Models\Challenge;
use App\Models\BonusMultiplier;
use Illuminate\Database\Seeder;

class ChallengeSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        // === CHALLENGES QUOTIDIENS ===
        Challenge::create([
            'title' => 'Première Course du Jour',
            'description' => 'Complétez votre première livraison aujourd\'hui',
            'type' => 'daily',
            'metric' => 'deliveries_count',
            'target_value' => 1,
            'reward_amount' => 100,
            'icon' => 'star',
            'color' => 'amber',
        ]);

        Challenge::create([
            'title' => 'Course Express',
            'description' => 'Effectuez 3 livraisons aujourd\'hui',
            'type' => 'daily',
            'metric' => 'deliveries_count',
            'target_value' => 3,
            'reward_amount' => 300,
            'icon' => 'speed',
            'color' => 'blue',
        ]);

        Challenge::create([
            'title' => 'Super Livreur',
            'description' => 'Effectuez 5 livraisons aujourd\'hui',
            'type' => 'daily',
            'metric' => 'deliveries_count',
            'target_value' => 5,
            'reward_amount' => 750,
            'icon' => 'fire',
            'color' => 'orange',
        ]);

        // === CHALLENGES HEBDOMADAIRES ===
        Challenge::create([
            'title' => 'Semaine Active',
            'description' => 'Effectuez 15 livraisons cette semaine',
            'type' => 'weekly',
            'metric' => 'deliveries_count',
            'target_value' => 15,
            'reward_amount' => 1500,
            'icon' => 'calendar',
            'color' => 'purple',
        ]);

        Challenge::create([
            'title' => 'Top Livreur',
            'description' => 'Effectuez 25 livraisons cette semaine',
            'type' => 'weekly',
            'metric' => 'deliveries_count',
            'target_value' => 25,
            'reward_amount' => 3000,
            'icon' => 'trophy',
            'color' => 'amber',
        ]);

        Challenge::create([
            'title' => 'Objectif 10 000',
            'description' => 'Gagnez 10 000 FCFA cette semaine',
            'type' => 'weekly',
            'metric' => 'earnings_amount',
            'target_value' => 10000,
            'reward_amount' => 1000,
            'icon' => 'rocket',
            'color' => 'green',
        ]);

        // === CHALLENGES MENSUELS ===
        Challenge::create([
            'title' => 'Champion du Mois',
            'description' => 'Effectuez 100 livraisons ce mois',
            'type' => 'monthly',
            'metric' => 'deliveries_count',
            'target_value' => 100,
            'reward_amount' => 10000,
            'icon' => 'crown',
            'color' => 'amber',
        ]);

        // === MILESTONES (une seule fois) ===
        Challenge::create([
            'title' => 'Bienvenue !',
            'description' => 'Complétez votre première livraison',
            'type' => 'milestone',
            'metric' => 'deliveries_count',
            'target_value' => 1,
            'reward_amount' => 500,
            'icon' => 'star',
            'color' => 'green',
        ]);

        Challenge::create([
            'title' => '10 Courses',
            'description' => 'Atteignez 10 livraisons au total',
            'type' => 'milestone',
            'metric' => 'deliveries_count',
            'target_value' => 10,
            'reward_amount' => 1000,
            'icon' => 'medal',
            'color' => 'blue',
        ]);

        Challenge::create([
            'title' => '50 Courses',
            'description' => 'Atteignez 50 livraisons au total',
            'type' => 'milestone',
            'metric' => 'deliveries_count',
            'target_value' => 50,
            'reward_amount' => 5000,
            'icon' => 'trophy',
            'color' => 'purple',
        ]);

        Challenge::create([
            'title' => 'Centurion',
            'description' => 'Atteignez 100 livraisons au total',
            'type' => 'milestone',
            'metric' => 'deliveries_count',
            'target_value' => 100,
            'reward_amount' => 15000,
            'icon' => 'crown',
            'color' => 'amber',
        ]);

        Challenge::create([
            'title' => 'Légende',
            'description' => 'Atteignez 500 livraisons au total',
            'type' => 'milestone',
            'metric' => 'deliveries_count',
            'target_value' => 500,
            'reward_amount' => 100000,
            'icon' => 'crown',
            'color' => 'red',
        ]);

        // === BONUS MULTIPLIERS ===
        BonusMultiplier::create([
            'name' => 'Rush Déjeuner',
            'description' => '+50 FCFA sur chaque livraison entre 12h et 14h',
            'type' => 'time_based',
            'multiplier' => 1.0,
            'flat_bonus' => 50,
            'conditions' => ['start_hour' => 12, 'end_hour' => 14],
            'is_active' => true,
        ]);

        BonusMultiplier::create([
            'name' => 'Rush Dîner',
            'description' => '+75 FCFA sur chaque livraison entre 19h et 21h',
            'type' => 'time_based',
            'multiplier' => 1.0,
            'flat_bonus' => 75,
            'conditions' => ['start_hour' => 19, 'end_hour' => 21],
            'is_active' => true,
        ]);

        BonusMultiplier::create([
            'name' => 'Weekend Boost',
            'description' => '+10% sur toutes les livraisons du weekend',
            'type' => 'time_based',
            'multiplier' => 1.10,
            'flat_bonus' => 0,
            'conditions' => ['days' => [6, 0]], // Saturday, Sunday
            'is_active' => false, // Désactivé par défaut
        ]);

        $this->command->info('✅ Challenges et Bonus créés avec succès !');
    }
}
