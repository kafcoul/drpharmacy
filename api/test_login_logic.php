<?php
// Mock implementation of the logic used in LoginController to verify SQL syntax compatibility
// This is a standalone script to test the query logic.

echo "Testing SQL Logic for Phone Normalization...\n";

// Simulating the input
$phoneInput = '0706070809';

// Simulating the query logic (we can't run actual SQL here without DB connection, but we can verify the PHP logic)
// The logic in LoginController is:
// $user = User::where('phone', $request->phone)
//            ->orWhereRaw("REPLACE(phone, ' ', '') = ?", [$request->phone])
//            ->orWhereRaw("REPLACE(phone, '-', '') = ?", [$request->phone])
//            ->first();

// Let's create a temporary SQLite Setup to verify the REPLACE function works as expected
try {
    $pdo = new PDO('sqlite::memory:');
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    // Create table
    $pdo->exec("CREATE TABLE users (id INTEGER PRIMARY KEY, phone TEXT)");

    // Insert user with spaces (simulate the problematic record)
    $pdo->exec("INSERT INTO users (phone) VALUES ('+225 07 06 07 08 09')");
    // Insert user with dashes
    $pdo->exec("INSERT INTO users (phone) VALUES ('07-00-00-00-00')");
    
    echo "Database created and seeded.\n";

    // Test Case 1: Search for '0706070809' (should match '+225 07 06 07 08 09' if we handle +225 removal + spaces)
    // Wait, my patch only used REPLACE(phone, ' ', '')
    // Before the patch, the user input '0706070809' was failing against '+225 07 06 07 08 09'.
    
    // My previous edit to LoginController was:
    // $query->where('phone', $request->phone)
    // ->orWhereRaw("REPLACE(phone, ' ', '') = ?", [$request->phone])
    // ...
    
    // Note: If the DB has '+225...', replacing spaces gives '+2250706070809'.
    // If input is '0706070809', it WON'T match '+2250706070809'.
    // So my fix might be INCOMPLETE if the prefix is present.
    
    // Let's test this hypothesis.
    
    $input = '0706070809';
    
    $stmt = $pdo->prepare("SELECT * FROM users WHERE REPLACE(phone, ' ', '') = ?");
    $stmt->execute([$input]);
    $result = $stmt->fetch(PDO::FETCH_ASSOC);
    
    if ($result) {
        echo "SUCCESS: Found user using simple replace.\n";
    } else {
        echo "FAILURE: Did not find user using simple replace. (Likely due to prefix +225)\n";
        
        // Let's try to match with 'ending with' logic or stripping +225
        $stmt2 = $pdo->prepare("SELECT * FROM users WHERE REPLACE(REPLACE(phone, ' ', ''), '+225', '') = ?");
        $stmt2->execute([$input]);
        $result2 = $stmt2->fetch(PDO::FETCH_ASSOC);
        
        if ($result2) {
             echo "SUCCESS: Found user by stripping +225 and spaces.\n";
        }
    }
    
    $normalizedPhone = '0706070809';
    $phoneWithoutZero = ltrim(ltrim($normalizedPhone, '+'), '0');
             
    // Liste des formats possibles à chercher matches the Controller logic
    $candidates = [
         $normalizedPhone,                          // 0706070809
         '+' . ltrim($normalizedPhone, '+'),        // +0706070809
         ltrim($normalizedPhone, '+'),              // 0706070809 (sans + si présent)
         '+225' . $normalizedPhone,                 // +2250706070809
         '+225' . $phoneWithoutZero,                // +225706070809
         '225' . $phoneWithoutZero,                 // 225706070809
    ];
    
    echo "Running Advanced Candidate Test...\n";
    $matched = false;
    foreach ($candidates as $candidate) {
        // echo "Checking candidate: $candidate\n";
        $stmt = $pdo->prepare("SELECT * FROM users WHERE REPLACE(phone, ' ', '') = ?");
        $stmt->execute([$candidate]);
        $result = $stmt->fetch(PDO::FETCH_ASSOC);
        if ($result) {
            echo "SUCCESS: Found user using candidate: $candidate\n";
            $matched = true;
            break;
        }
    }
    
    if (!$matched) {
        echo "FAILURE: Could not find user with any candidate.\n";
    }

} catch (PDOException $e) {
    echo "DB Error: " . $e->getMessage();
}
