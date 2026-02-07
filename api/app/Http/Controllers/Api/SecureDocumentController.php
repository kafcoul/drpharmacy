<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;
use Symfony\Component\HttpFoundation\StreamedResponse;
use Illuminate\Support\Facades\Log;

class SecureDocumentController extends Controller
{
    /**
     * Serve a secure document with proper authorization checks.
     * 
     * @param Request $request
     * @param string $type Document type (pharmacy-licenses, id-cards, prescriptions, etc.)
     * @param string $filename The filename to serve
     * @return StreamedResponse|\Illuminate\Http\JsonResponse
     */
    public function serve(Request $request, string $type, string $filename)
    {
        $user = $request->user();
        
        if (!$user) {
            return response()->json(['message' => 'Unauthorized'], 401);
        }

        // Build the full path
        $path = "{$type}/{$filename}";
        
        // Check if file exists in private storage
        if (!Storage::disk('private')->exists($path)) {
            Log::warning("Document not found: {$path}", ['user_id' => $user->id]);
            return response()->json(['message' => 'Document not found'], 404);
        }

        // Authorization check based on document type
        if (!$this->canAccessDocument($user, $type, $filename)) {
            Log::warning("Unauthorized document access attempt", [
                'user_id' => $user->id,
                'document' => $path,
            ]);
            return response()->json(['message' => 'Forbidden'], 403);
        }

        // Log the access
        Log::info("Document accessed", [
            'user_id' => $user->id,
            'document' => $path,
        ]);

        // Stream the file
        return Storage::disk('private')->download($path);
    }

    /**
     * Check if the user can access the specified document.
     * 
     * @param \App\Models\User $user
     * @param string $type
     * @param string $filename
     * @return bool
     */
    protected function canAccessDocument($user, string $type, string $filename): bool
    {
        // Admins can access all documents
        if ($user->isAdmin()) {
            return true;
        }

        switch ($type) {
            case 'pharmacy-licenses':
            case 'pharmacy-id-cards':
                return $this->canAccessPharmacyDocument($user, $filename);
                
            case 'prescriptions':
                return $this->canAccessPrescription($user, $filename);
                
            case 'courier-documents':
                return $this->canAccessCourierDocument($user, $filename);
                
            default:
                return false;
        }
    }

    /**
     * Check if user can access pharmacy documents.
     */
    protected function canAccessPharmacyDocument($user, string $filename): bool
    {
        // Pharmacy users can only access their own documents
        if ($user->role === 'pharmacy') {
            $pharmacy = $user->pharmacy;
            if ($pharmacy) {
                // Check if filename belongs to this pharmacy
                return str_contains($filename, $pharmacy->id) || 
                       $pharmacy->license_document === $filename ||
                       $pharmacy->id_card_document === $filename;
            }
        }

        return false;
    }

    /**
     * Check if user can access prescription documents.
     */
    protected function canAccessPrescription($user, string $filename): bool
    {
        // Extract user ID from path if present (format: {user_id}/filename.ext)
        $pathParts = explode('/', $filename);
        $ownerId = count($pathParts) > 1 ? $pathParts[0] : null;

        // Customers can access their own prescriptions
        if ($user->role === 'customer') {
            // Check if the prescription belongs to this customer (by path user_id)
            if ($ownerId && $ownerId == $user->id) {
                return true;
            }

            // Also check via prescriptions table
            $hasAccess = \App\Models\Prescription::where('customer_id', $user->id)
                ->where('images', 'LIKE', "%{$filename}%")
                ->exists();
            
            if ($hasAccess) {
                return true;
            }

            // Fallback: check if prescription belongs to user's orders
            $hasOrderAccess = $user->orders()
                ->where('prescription_path', 'LIKE', "%{$filename}%")
                ->exists();
            
            if ($hasOrderAccess) {
                return true;
            }
        }

        // Pharmacies can access all prescriptions (they need to view/process them)
        if ($user->role === 'pharmacy') {
            return true;
        }

        return false;
    }

    /**
     * Check if user can access courier documents.
     */
    protected function canAccessCourierDocument($user, string $filename): bool
    {
        // Couriers can only access their own documents
        if ($user->role === 'courier') {
            $courier = $user->courier;
            if ($courier) {
                return str_contains($filename, $courier->id) ||
                       $courier->license_document === $filename ||
                       $courier->id_document === $filename;
            }
        }

        return false;
    }

    /**
     * Get a temporary signed URL for a private document (useful for mobile apps).
     * 
     * @param Request $request
     * @param string $type
     * @param string $filename
     * @return \Illuminate\Http\JsonResponse
     */
    public function getTemporaryUrl(Request $request, string $type, string $filename)
    {
        $user = $request->user();
        
        if (!$user) {
            return response()->json(['message' => 'Unauthorized'], 401);
        }

        $path = "{$type}/{$filename}";
        
        if (!Storage::disk('private')->exists($path)) {
            return response()->json(['message' => 'Document not found'], 404);
        }

        if (!$this->canAccessDocument($user, $type, $filename)) {
            return response()->json(['message' => 'Forbidden'], 403);
        }

        // Generate a temporary URL that expires in 5 minutes
        // Note: This only works with S3 or similar cloud storage
        // For local storage, use the serve endpoint instead
        try {
            $url = Storage::disk('private')->temporaryUrl(
                $path,
                now()->addMinutes(5)
            );

            return response()->json([
                'url' => $url,
                'expires_at' => now()->addMinutes(5)->toISOString(),
            ]);
        } catch (\Exception $e) {
            // Fallback for local storage - return the secure download URL
            return response()->json([
                'url' => route('secure.document', ['type' => $type, 'filename' => $filename]),
                'method' => 'GET',
                'requires_auth' => true,
            ]);
        }
    }
}
