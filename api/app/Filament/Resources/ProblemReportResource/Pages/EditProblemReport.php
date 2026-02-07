<?php

namespace App\Filament\Resources\ProblemReportResource\Pages;

use App\Filament\Resources\ProblemReportResource;
use Filament\Actions;
use Filament\Resources\Pages\EditRecord;

class EditProblemReport extends EditRecord
{
    protected static string $resource = ProblemReportResource::class;

    protected function getHeaderActions(): array
    {
        return [
            Actions\DeleteAction::make(),
        ];
    }
}
