<?php

namespace App\Filament\Resources\ProblemReportResource\Pages;

use App\Filament\Resources\ProblemReportResource;
use Filament\Actions;
use Filament\Resources\Pages\ListRecords;

class ListProblemReports extends ListRecords
{
    protected static string $resource = ProblemReportResource::class;

    protected function getHeaderActions(): array
    {
        return [
            Actions\CreateAction::make(),
        ];
    }
}
