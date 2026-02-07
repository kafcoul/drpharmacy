<div class="space-y-4">
    <div class="grid grid-cols-2 gap-4">
        {{-- Disponibles --}}
        <div class="bg-green-50 dark:bg-green-900/20 rounded-lg p-4 text-center">
            <div class="text-3xl font-bold text-green-600 dark:text-green-400">
                {{ $stats['available'] }}
            </div>
            <div class="text-sm text-green-700 dark:text-green-300 mt-1">
                🟢 Disponibles
            </div>
        </div>

        {{-- Occupés --}}
        <div class="bg-yellow-50 dark:bg-yellow-900/20 rounded-lg p-4 text-center">
            <div class="text-3xl font-bold text-yellow-600 dark:text-yellow-400">
                {{ $stats['busy'] }}
            </div>
            <div class="text-sm text-yellow-700 dark:text-yellow-300 mt-1">
                🟡 Occupés
            </div>
        </div>

        {{-- Hors ligne --}}
        <div class="bg-gray-50 dark:bg-gray-800 rounded-lg p-4 text-center">
            <div class="text-3xl font-bold text-gray-600 dark:text-gray-400">
                {{ $stats['offline'] }}
            </div>
            <div class="text-sm text-gray-700 dark:text-gray-300 mt-1">
                ⚫ Hors ligne
            </div>
        </div>

        {{-- Actifs récemment --}}
        <div class="bg-blue-50 dark:bg-blue-900/20 rounded-lg p-4 text-center">
            <div class="text-3xl font-bold text-blue-600 dark:text-blue-400">
                {{ $stats['recently_active'] }}
            </div>
            <div class="text-sm text-blue-700 dark:text-blue-300 mt-1">
                📍 Actifs (-30min)
            </div>
        </div>
    </div>

    <div class="border-t pt-4 dark:border-gray-700">
        <div class="flex justify-between items-center">
            <span class="text-gray-600 dark:text-gray-400">Total livreurs:</span>
            <span class="font-semibold text-gray-900 dark:text-white">{{ $stats['total'] }}</span>
        </div>
    </div>

    @if($stats['available'] == 0)
        <div class="bg-red-50 dark:bg-red-900/20 border border-red-200 dark:border-red-800 rounded-lg p-3">
            <p class="text-sm text-red-700 dark:text-red-300">
                ⚠️ <strong>Attention:</strong> Aucun livreur disponible actuellement. 
                L'assignation automatique ne pourra pas fonctionner.
            </p>
        </div>
    @endif
</div>
