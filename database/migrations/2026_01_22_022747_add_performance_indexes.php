<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     * 
     * Security Audit Week 2 - Performance Indexes
     * Ces index améliorent les performances des requêtes fréquentes
     */
    public function up(): void
    {
        // Index sur la table orders
        if (Schema::hasTable('orders')) {
            Schema::table('orders', function (Blueprint $table) {
                // Vérifier si les colonnes existent avant de créer les index
                if (Schema::hasColumn('orders', 'status') && !$this->indexExists('orders', 'idx_orders_status')) {
                    $table->index('status', 'idx_orders_status');
                }
                if (Schema::hasColumn('orders', 'customer_id') && !$this->indexExists('orders', 'idx_orders_customer')) {
                    $table->index('customer_id', 'idx_orders_customer');
                }
                if (Schema::hasColumn('orders', 'pharmacy_id') && !$this->indexExists('orders', 'idx_orders_pharmacy')) {
                    $table->index('pharmacy_id', 'idx_orders_pharmacy');
                }
                if (Schema::hasColumn('orders', 'status') && Schema::hasColumn('orders', 'pharmacy_id') && !$this->indexExists('orders', 'idx_orders_status_pharmacy')) {
                    $table->index(['status', 'pharmacy_id'], 'idx_orders_status_pharmacy');
                }
                if (Schema::hasColumn('orders', 'status') && Schema::hasColumn('orders', 'customer_id') && !$this->indexExists('orders', 'idx_orders_status_customer')) {
                    $table->index(['status', 'customer_id'], 'idx_orders_status_customer');
                }
                if (Schema::hasColumn('orders', 'created_at') && !$this->indexExists('orders', 'idx_orders_created')) {
                    $table->index('created_at', 'idx_orders_created');
                }
            });
        }

        // Index sur la table deliveries
        if (Schema::hasTable('deliveries')) {
            Schema::table('deliveries', function (Blueprint $table) {
                if (Schema::hasColumn('deliveries', 'status') && !$this->indexExists('deliveries', 'idx_deliveries_status')) {
                    $table->index('status', 'idx_deliveries_status');
                }
                if (Schema::hasColumn('deliveries', 'courier_id') && !$this->indexExists('deliveries', 'idx_deliveries_courier')) {
                    $table->index('courier_id', 'idx_deliveries_courier');
                }
                if (Schema::hasColumn('deliveries', 'courier_id') && Schema::hasColumn('deliveries', 'status') && !$this->indexExists('deliveries', 'idx_deliveries_courier_status')) {
                    $table->index(['courier_id', 'status'], 'idx_deliveries_courier_status');
                }
                if (Schema::hasColumn('deliveries', 'status') && Schema::hasColumn('deliveries', 'courier_id') && !$this->indexExists('deliveries', 'idx_deliveries_pending')) {
                    $table->index(['status', 'courier_id'], 'idx_deliveries_pending');
                }
            });
        }

        // Index sur la table products
        if (Schema::hasTable('products')) {
            Schema::table('products', function (Blueprint $table) {
                if (Schema::hasColumn('products', 'pharmacy_id') && !$this->indexExists('products', 'idx_products_pharmacy')) {
                    $table->index('pharmacy_id', 'idx_products_pharmacy');
                }
                if (Schema::hasColumn('products', 'category_id') && !$this->indexExists('products', 'idx_products_category')) {
                    $table->index('category_id', 'idx_products_category');
                }
                if (Schema::hasColumn('products', 'is_available') && !$this->indexExists('products', 'idx_products_available')) {
                    $table->index('is_available', 'idx_products_available');
                }
                if (Schema::hasColumn('products', 'pharmacy_id') && Schema::hasColumn('products', 'is_available') && !$this->indexExists('products', 'idx_products_pharmacy_available')) {
                    $table->index(['pharmacy_id', 'is_available'], 'idx_products_pharmacy_available');
                }
            });
        }

        // Index sur la table prescriptions
        if (Schema::hasTable('prescriptions')) {
            Schema::table('prescriptions', function (Blueprint $table) {
                if (Schema::hasColumn('prescriptions', 'customer_id') && !$this->indexExists('prescriptions', 'idx_prescriptions_customer')) {
                    $table->index('customer_id', 'idx_prescriptions_customer');
                }
                if (Schema::hasColumn('prescriptions', 'status') && !$this->indexExists('prescriptions', 'idx_prescriptions_status')) {
                    $table->index('status', 'idx_prescriptions_status');
                }
            });
        }

        // Index sur la table notifications
        if (Schema::hasTable('notifications')) {
            Schema::table('notifications', function (Blueprint $table) {
                if (!$this->indexExists('notifications', 'idx_notifications_unread')) {
                    $table->index(['notifiable_type', 'notifiable_id', 'read_at'], 'idx_notifications_unread');
                }
            });
        }

        // Index sur la table transactions (paiements)
        if (Schema::hasTable('transactions')) {
            Schema::table('transactions', function (Blueprint $table) {
                if (Schema::hasColumn('transactions', 'status') && !$this->indexExists('transactions', 'idx_transactions_status')) {
                    $table->index('status', 'idx_transactions_status');
                }
                if (Schema::hasColumn('transactions', 'order_id') && !$this->indexExists('transactions', 'idx_transactions_order')) {
                    $table->index('order_id', 'idx_transactions_order');
                }
                if (Schema::hasColumn('transactions', 'reference') && !$this->indexExists('transactions', 'idx_transactions_reference')) {
                    $table->index('reference', 'idx_transactions_reference');
                }
            });
        }
    }

    /**
     * Vérifier si un index existe
     */
    protected function indexExists(string $table, string $indexName): bool
    {
        $connection = Schema::getConnection();
        $driver = $connection->getDriverName();
        
        if ($driver === 'sqlite') {
            $indexes = $connection->select("PRAGMA index_list('{$table}')");
            foreach ($indexes as $index) {
                if ($index->name === $indexName) {
                    return true;
                }
            }
            return false;
        }
        
        // Pour MySQL/PostgreSQL
        $indexes = $connection->getDoctrineSchemaManager()->listTableIndexes($table);
        return isset($indexes[$indexName]);
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        if (Schema::hasTable('orders')) {
            Schema::table('orders', function (Blueprint $table) {
                if ($this->indexExists('orders', 'idx_orders_status')) $table->dropIndex('idx_orders_status');
                if ($this->indexExists('orders', 'idx_orders_customer')) $table->dropIndex('idx_orders_customer');
                if ($this->indexExists('orders', 'idx_orders_pharmacy')) $table->dropIndex('idx_orders_pharmacy');
                if ($this->indexExists('orders', 'idx_orders_status_pharmacy')) $table->dropIndex('idx_orders_status_pharmacy');
                if ($this->indexExists('orders', 'idx_orders_status_customer')) $table->dropIndex('idx_orders_status_customer');
                if ($this->indexExists('orders', 'idx_orders_created')) $table->dropIndex('idx_orders_created');
            });
        }

        if (Schema::hasTable('deliveries')) {
            Schema::table('deliveries', function (Blueprint $table) {
                if ($this->indexExists('deliveries', 'idx_deliveries_status')) $table->dropIndex('idx_deliveries_status');
                if ($this->indexExists('deliveries', 'idx_deliveries_courier')) $table->dropIndex('idx_deliveries_courier');
                if ($this->indexExists('deliveries', 'idx_deliveries_courier_status')) $table->dropIndex('idx_deliveries_courier_status');
                if ($this->indexExists('deliveries', 'idx_deliveries_pending')) $table->dropIndex('idx_deliveries_pending');
            });
        }

        if (Schema::hasTable('products')) {
            Schema::table('products', function (Blueprint $table) {
                if ($this->indexExists('products', 'idx_products_pharmacy')) $table->dropIndex('idx_products_pharmacy');
                if ($this->indexExists('products', 'idx_products_category')) $table->dropIndex('idx_products_category');
                if ($this->indexExists('products', 'idx_products_available')) $table->dropIndex('idx_products_available');
                if ($this->indexExists('products', 'idx_products_pharmacy_available')) $table->dropIndex('idx_products_pharmacy_available');
            });
        }

        if (Schema::hasTable('prescriptions')) {
            Schema::table('prescriptions', function (Blueprint $table) {
                if ($this->indexExists('prescriptions', 'idx_prescriptions_customer')) $table->dropIndex('idx_prescriptions_customer');
                if ($this->indexExists('prescriptions', 'idx_prescriptions_status')) $table->dropIndex('idx_prescriptions_status');
            });
        }

        if (Schema::hasTable('notifications')) {
            Schema::table('notifications', function (Blueprint $table) {
                if ($this->indexExists('notifications', 'idx_notifications_unread')) $table->dropIndex('idx_notifications_unread');
            });
        }

        if (Schema::hasTable('transactions')) {
            Schema::table('transactions', function (Blueprint $table) {
                if ($this->indexExists('transactions', 'idx_transactions_status')) $table->dropIndex('idx_transactions_status');
                if ($this->indexExists('transactions', 'idx_transactions_order')) $table->dropIndex('idx_transactions_order');
                if ($this->indexExists('transactions', 'idx_transactions_reference')) $table->dropIndex('idx_transactions_reference');
            });
        }
    }
};
