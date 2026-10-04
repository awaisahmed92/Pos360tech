<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('shop_documents', function (Blueprint $table) {
            $table->id();
            $table->foreignId('company_id')->constrained()->cascadeOnDelete();
            $table->string('entity', 40);
            $table->uuid('client_uuid');
            $table->json('payload');
            $table->timestamps();
            $table->unique(['company_id', 'entity', 'client_uuid']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('shop_documents');
    }
};
