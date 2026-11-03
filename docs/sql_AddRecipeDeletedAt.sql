BEGIN TRANSACTION;
ALTER TABLE [Recipes] ADD [DeletedAt] datetime2 NULL;

INSERT INTO [__EFMigrationsHistory] ([MigrationId], [ProductVersion])
VALUES (N'20261031073352_AddRecipeDeletedAt', N'10.0.14');

COMMIT;
GO

