<?php

namespace App\Mail;

use Barryvdh\DomPDF\Facade\Pdf;
use Illuminate\Bus\Queueable;
use Illuminate\Mail\Mailable;
use Illuminate\Mail\Mailables\Content;
use Illuminate\Mail\Mailables\Envelope;
use Illuminate\Queue\SerializesModels;
use PhpOffice\PhpSpreadsheet\Spreadsheet;
use PhpOffice\PhpSpreadsheet\Writer\Xlsx;
use PhpOffice\PhpSpreadsheet\Writer\Csv;

class PharmacyStatementMail extends Mailable
{
    use Queueable, SerializesModels;

    public array $statementData;

    /**
     * Create a new message instance.
     */
    public function __construct(array $statementData)
    {
        $this->statementData = $statementData;
    }

    /**
     * Get the message envelope.
     */
    public function envelope(): Envelope
    {
        $pharmacy = $this->statementData['pharmacy'];
        $periodStart = $this->statementData['period_start']->format('d/m/Y');
        $periodEnd = $this->statementData['period_end']->format('d/m/Y');
        
        return new Envelope(
            subject: "Relevé de compte - {$pharmacy->name} ({$periodStart} - {$periodEnd})",
        );
    }

    /**
     * Get the message content definition.
     */
    public function content(): Content
    {
        return new Content(
            view: 'emails.pharmacy-statement',
        );
    }

    /**
     * Get the attachments for the message.
     *
     * @return array<int, \Illuminate\Mail\Mailables\Attachment>
     */
    public function attachments(): array
    {
        $format = $this->statementData['format'];
        $pharmacy = $this->statementData['pharmacy'];
        $periodStart = $this->statementData['period_start']->format('Y-m-d');
        $periodEnd = $this->statementData['period_end']->format('Y-m-d');
        $filename = "releve_{$pharmacy->id}_{$periodStart}_{$periodEnd}";

        return match ($format) {
            'pdf' => [$this->generatePdfAttachment($filename)],
            'excel' => [$this->generateExcelAttachment($filename)],
            'csv' => [$this->generateCsvAttachment($filename)],
            default => [$this->generatePdfAttachment($filename)],
        };
    }

    /**
     * Générer le PDF en pièce jointe
     */
    protected function generatePdfAttachment(string $filename): \Illuminate\Mail\Mailables\Attachment
    {
        $pdf = Pdf::loadView('pdf.pharmacy-statement', $this->statementData);
        
        return \Illuminate\Mail\Mailables\Attachment::fromData(
            fn () => $pdf->output(),
            "{$filename}.pdf"
        )->withMime('application/pdf');
    }

    /**
     * Générer le fichier Excel en pièce jointe
     */
    protected function generateExcelAttachment(string $filename): \Illuminate\Mail\Mailables\Attachment
    {
        $spreadsheet = $this->createSpreadsheet();
        $writer = new Xlsx($spreadsheet);
        
        $tempFile = tempnam(sys_get_temp_dir(), 'statement_');
        $writer->save($tempFile);
        
        return \Illuminate\Mail\Mailables\Attachment::fromPath($tempFile)
            ->as("{$filename}.xlsx")
            ->withMime('application/vnd.openxmlformats-officedocument.spreadsheetml.sheet');
    }

    /**
     * Générer le fichier CSV en pièce jointe
     */
    protected function generateCsvAttachment(string $filename): \Illuminate\Mail\Mailables\Attachment
    {
        $spreadsheet = $this->createSpreadsheet();
        $writer = new Csv($spreadsheet);
        $writer->setDelimiter(';');
        $writer->setEnclosure('"');
        
        $tempFile = tempnam(sys_get_temp_dir(), 'statement_');
        $writer->save($tempFile);
        
        return \Illuminate\Mail\Mailables\Attachment::fromPath($tempFile)
            ->as("{$filename}.csv")
            ->withMime('text/csv');
    }

    /**
     * Créer le spreadsheet pour Excel/CSV
     */
    protected function createSpreadsheet(): Spreadsheet
    {
        $spreadsheet = new Spreadsheet();
        $sheet = $spreadsheet->getActiveSheet();
        
        $pharmacy = $this->statementData['pharmacy'];
        $transactions = $this->statementData['transactions'];
        
        // En-tête
        $sheet->setCellValue('A1', 'Relevé de compte - ' . $pharmacy->name);
        $sheet->setCellValue('A2', 'Période: ' . $this->statementData['period_start']->format('d/m/Y') . ' - ' . $this->statementData['period_end']->format('d/m/Y'));
        $sheet->setCellValue('A3', '');
        
        // Résumé
        $sheet->setCellValue('A4', 'Solde actuel:');
        $sheet->setCellValue('B4', number_format($this->statementData['balance'], 0, ',', ' ') . ' FCFA');
        $sheet->setCellValue('A5', 'Total crédits:');
        $sheet->setCellValue('B5', number_format($this->statementData['total_credits'], 0, ',', ' ') . ' FCFA');
        $sheet->setCellValue('A6', 'Total débits:');
        $sheet->setCellValue('B6', number_format($this->statementData['total_debits'], 0, ',', ' ') . ' FCFA');
        $sheet->setCellValue('A7', '');
        
        // En-têtes du tableau
        $sheet->setCellValue('A8', 'Date');
        $sheet->setCellValue('B8', 'Type');
        $sheet->setCellValue('C8', 'Description');
        $sheet->setCellValue('D8', 'Montant (FCFA)');
        
        // Données des transactions
        $row = 9;
        foreach ($transactions as $transaction) {
            $sheet->setCellValue("A{$row}", $transaction->created_at->format('d/m/Y H:i'));
            $sheet->setCellValue("B{$row}", $transaction->type === 'credit' ? 'Crédit' : 'Débit');
            $sheet->setCellValue("C{$row}", $transaction->description ?? '-');
            $amount = $transaction->type === 'credit' ? "+{$transaction->amount}" : "-{$transaction->amount}";
            $sheet->setCellValue("D{$row}", $amount);
            $row++;
        }
        
        return $spreadsheet;
    }
}
