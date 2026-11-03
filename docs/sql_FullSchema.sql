IF OBJECT_ID(N'[__EFMigrationsHistory]') IS NULL
BEGIN
    CREATE TABLE [__EFMigrationsHistory] (
        [MigrationId] nvarchar(150) NOT NULL,
        [ProductVersion] nvarchar(32) NOT NULL,
        CONSTRAINT [PK___EFMigrationsHistory] PRIMARY KEY ([MigrationId])
    );
END;
GO

BEGIN TRANSACTION;
IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20261028153143_InitialCreate'
)
BEGIN
    CREATE TABLE [Categories] (
        [Id] int NOT NULL IDENTITY,
        [Name] nvarchar(100) NOT NULL,
        CONSTRAINT [PK_Categories] PRIMARY KEY ([Id])
    );
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20261028153143_InitialCreate'
)
BEGIN
    CREATE TABLE [RescueNodes] (
        [Id] int NOT NULL IDENTITY,
        [IssueCode] nvarchar(50) NOT NULL,
        [QuestionText] nvarchar(500) NULL,
        [AdviceText] nvarchar(2000) NULL,
        [Explanation] nvarchar(2000) NULL,
        [SafetyNote] nvarchar(1000) NULL,
        CONSTRAINT [PK_RescueNodes] PRIMARY KEY ([Id]),
        CONSTRAINT [CK_RescueNodes_QuestionOrAdvice] CHECK (([QuestionText] IS NULL AND [AdviceText] IS NOT NULL) OR ([QuestionText] IS NOT NULL AND [AdviceText] IS NULL))
    );
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20261028153143_InitialCreate'
)
BEGIN
    CREATE TABLE [Users] (
        [Id] int NOT NULL IDENTITY,
        [Email] nvarchar(256) NOT NULL,
        [PasswordHash] nvarchar(256) NOT NULL,
        [FullName] nvarchar(100) NOT NULL,
        [FaceEmbedding] varbinary(max) NULL,
        [FaceDim] int NULL,
        [FaceEnrolledAt] datetime2 NULL,
        [CreatedAt] datetime2 NOT NULL DEFAULT (SYSUTCDATETIME()),
        CONSTRAINT [PK_Users] PRIMARY KEY ([Id])
    );
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20261028153143_InitialCreate'
)
BEGIN
    CREATE TABLE [Recipes] (
        [Id] int NOT NULL IDENTITY,
        [Name] nvarchar(200) NOT NULL,
        [Description] nvarchar(2000) NOT NULL,
        [ImageUrl] nvarchar(500) NULL,
        [Difficulty] int NOT NULL,
        [PrepMinutes] int NOT NULL,
        [CookMinutes] int NOT NULL,
        [BaseServings] int NOT NULL,
        [CategoryId] int NOT NULL,
        CONSTRAINT [PK_Recipes] PRIMARY KEY ([Id]),
        CONSTRAINT [CK_Recipes_BaseServings] CHECK ([BaseServings] >= 1),
        CONSTRAINT [CK_Recipes_Difficulty] CHECK ([Difficulty] BETWEEN 1 AND 3),
        CONSTRAINT [CK_Recipes_Minutes] CHECK ([PrepMinutes] >= 0 AND [CookMinutes] >= 0),
        CONSTRAINT [FK_Recipes_Categories_CategoryId] FOREIGN KEY ([CategoryId]) REFERENCES [Categories] ([Id]) ON DELETE NO ACTION
    );
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20261028153143_InitialCreate'
)
BEGIN
    CREATE TABLE [RescueOptions] (
        [Id] int NOT NULL IDENTITY,
        [NodeId] int NOT NULL,
        [AnswerCode] nvarchar(50) NOT NULL,
        [Text] nvarchar(300) NOT NULL,
        [NextNodeId] int NOT NULL,
        CONSTRAINT [PK_RescueOptions] PRIMARY KEY ([Id]),
        CONSTRAINT [FK_RescueOptions_RescueNodes_NextNodeId] FOREIGN KEY ([NextNodeId]) REFERENCES [RescueNodes] ([Id]) ON DELETE NO ACTION,
        CONSTRAINT [FK_RescueOptions_RescueNodes_NodeId] FOREIGN KEY ([NodeId]) REFERENCES [RescueNodes] ([Id]) ON DELETE CASCADE
    );
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20261028153143_InitialCreate'
)
BEGIN
    CREATE TABLE [CookingSessions] (
        [Id] int NOT NULL IDENTITY,
        [UserId] int NOT NULL,
        [RecipeId] int NOT NULL,
        [Servings] int NOT NULL,
        [CurrentStep] int NOT NULL,
        [Status] nvarchar(20) NOT NULL,
        [StartedAt] datetime2 NOT NULL,
        [UpdatedAt] datetime2 NOT NULL,
        [CompletedAt] datetime2 NULL,
        CONSTRAINT [PK_CookingSessions] PRIMARY KEY ([Id]),
        CONSTRAINT [CK_CookingSessions_CurrentStep] CHECK ([CurrentStep] >= 1),
        CONSTRAINT [CK_CookingSessions_Servings] CHECK ([Servings] BETWEEN 1 AND 20),
        CONSTRAINT [FK_CookingSessions_Recipes_RecipeId] FOREIGN KEY ([RecipeId]) REFERENCES [Recipes] ([Id]) ON DELETE NO ACTION,
        CONSTRAINT [FK_CookingSessions_Users_UserId] FOREIGN KEY ([UserId]) REFERENCES [Users] ([Id]) ON DELETE CASCADE
    );
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20261028153143_InitialCreate'
)
BEGIN
    CREATE TABLE [RecipeIngredients] (
        [Id] int NOT NULL IDENTITY,
        [RecipeId] int NOT NULL,
        [Name] nvarchar(200) NOT NULL,
        [Quantity] decimal(10,2) NOT NULL,
        [Unit] nvarchar(30) NOT NULL,
        [IsOptional] bit NOT NULL,
        CONSTRAINT [PK_RecipeIngredients] PRIMARY KEY ([Id]),
        CONSTRAINT [CK_RecipeIngredients_Quantity] CHECK ([Quantity] >= 0),
        CONSTRAINT [FK_RecipeIngredients_Recipes_RecipeId] FOREIGN KEY ([RecipeId]) REFERENCES [Recipes] ([Id]) ON DELETE CASCADE
    );
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20261028153143_InitialCreate'
)
BEGIN
    CREATE TABLE [RecipeSteps] (
        [Id] int NOT NULL IDENTITY,
        [RecipeId] int NOT NULL,
        [StepNumber] int NOT NULL,
        [Instruction] nvarchar(2000) NOT NULL,
        [TimerSeconds] int NOT NULL,
        CONSTRAINT [PK_RecipeSteps] PRIMARY KEY ([Id]),
        CONSTRAINT [CK_RecipeSteps_StepNumber] CHECK ([StepNumber] >= 1),
        CONSTRAINT [CK_RecipeSteps_TimerSeconds] CHECK ([TimerSeconds] >= 0),
        CONSTRAINT [FK_RecipeSteps_Recipes_RecipeId] FOREIGN KEY ([RecipeId]) REFERENCES [Recipes] ([Id]) ON DELETE CASCADE
    );
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20261028153143_InitialCreate'
)
BEGIN
    CREATE TABLE [RescueHistory] (
        [Id] int NOT NULL IDENTITY,
        [UserId] int NOT NULL,
        [IssueCode] nvarchar(50) NOT NULL,
        [RecipeId] int NULL,
        [Resolved] bit NOT NULL,
        [CreatedAt] datetime2 NOT NULL DEFAULT (SYSUTCDATETIME()),
        CONSTRAINT [PK_RescueHistory] PRIMARY KEY ([Id]),
        CONSTRAINT [FK_RescueHistory_Recipes_RecipeId] FOREIGN KEY ([RecipeId]) REFERENCES [Recipes] ([Id]) ON DELETE SET NULL,
        CONSTRAINT [FK_RescueHistory_Users_UserId] FOREIGN KEY ([UserId]) REFERENCES [Users] ([Id]) ON DELETE CASCADE
    );
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20261028153143_InitialCreate'
)
BEGIN
    CREATE UNIQUE INDEX [IX_Categories_Name] ON [Categories] ([Name]);
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20261028153143_InitialCreate'
)
BEGIN
    CREATE INDEX [IX_CookingSessions_RecipeId] ON [CookingSessions] ([RecipeId]);
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20261028153143_InitialCreate'
)
BEGIN
    CREATE INDEX [IX_CookingSessions_UserId_Status] ON [CookingSessions] ([UserId], [Status]);
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20261028153143_InitialCreate'
)
BEGIN
    CREATE INDEX [IX_RecipeIngredients_RecipeId] ON [RecipeIngredients] ([RecipeId]);
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20261028153143_InitialCreate'
)
BEGIN
    CREATE INDEX [IX_Recipes_CategoryId] ON [Recipes] ([CategoryId]);
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20261028153143_InitialCreate'
)
BEGIN
    CREATE INDEX [IX_Recipes_Name] ON [Recipes] ([Name]);
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20261028153143_InitialCreate'
)
BEGIN
    CREATE UNIQUE INDEX [IX_RecipeSteps_RecipeId_StepNumber] ON [RecipeSteps] ([RecipeId], [StepNumber]);
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20261028153143_InitialCreate'
)
BEGIN
    CREATE INDEX [IX_RescueHistory_RecipeId] ON [RescueHistory] ([RecipeId]);
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20261028153143_InitialCreate'
)
BEGIN
    CREATE INDEX [IX_RescueHistory_UserId_Resolved] ON [RescueHistory] ([UserId], [Resolved]);
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20261028153143_InitialCreate'
)
BEGIN
    CREATE INDEX [IX_RescueNodes_IssueCode] ON [RescueNodes] ([IssueCode]);
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20261028153143_InitialCreate'
)
BEGIN
    CREATE INDEX [IX_RescueOptions_NextNodeId] ON [RescueOptions] ([NextNodeId]);
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20261028153143_InitialCreate'
)
BEGIN
    CREATE UNIQUE INDEX [IX_RescueOptions_NodeId_AnswerCode] ON [RescueOptions] ([NodeId], [AnswerCode]);
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20261028153143_InitialCreate'
)
BEGIN
    CREATE UNIQUE INDEX [IX_Users_Email] ON [Users] ([Email]);
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20261028153143_InitialCreate'
)
BEGIN
    INSERT INTO [__EFMigrationsHistory] ([MigrationId], [ProductVersion])
    VALUES (N'20261028153143_InitialCreate', N'10.0.14');
END;

COMMIT;
GO

BEGIN TRANSACTION;
IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20261028155440_AddEmailCodes'
)
BEGIN
    ALTER TABLE [Users] ADD [EmailConfirmed] bit NOT NULL DEFAULT CAST(0 AS bit);
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20261028155440_AddEmailCodes'
)
BEGIN
    UPDATE Users SET EmailConfirmed = 1
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20261028155440_AddEmailCodes'
)
BEGIN
    CREATE TABLE [EmailCodes] (
        [Id] int NOT NULL IDENTITY,
        [UserId] int NOT NULL,
        [Purpose] nvarchar(20) NOT NULL,
        [CodeHash] nvarchar(100) NOT NULL,
        [ExpiresAt] datetime2 NOT NULL,
        [Attempts] int NOT NULL,
        [CreatedAt] datetime2 NOT NULL,
        CONSTRAINT [PK_EmailCodes] PRIMARY KEY ([Id]),
        CONSTRAINT [FK_EmailCodes_Users_UserId] FOREIGN KEY ([UserId]) REFERENCES [Users] ([Id]) ON DELETE CASCADE
    );
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20261028155440_AddEmailCodes'
)
BEGIN
    CREATE INDEX [IX_EmailCodes_UserId_Purpose] ON [EmailCodes] ([UserId], [Purpose]);
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20261028155440_AddEmailCodes'
)
BEGIN
    INSERT INTO [__EFMigrationsHistory] ([MigrationId], [ProductVersion])
    VALUES (N'20261028155440_AddEmailCodes', N'10.0.14');
END;

COMMIT;
GO

BEGIN TRANSACTION;
IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20261029103934_AddRescueIssueTitle'
)
BEGIN
    ALTER TABLE [RescueNodes] ADD [IssueTitle] nvarchar(200) NULL;
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20261029103934_AddRescueIssueTitle'
)
BEGIN
    INSERT INTO [__EFMigrationsHistory] ([MigrationId], [ProductVersion])
    VALUES (N'20261029103934_AddRescueIssueTitle', N'10.0.14');
END;

COMMIT;
GO

BEGIN TRANSACTION;
IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20261031014955_AddGoogleId'
)
BEGIN
    ALTER TABLE [Users] ADD [GoogleId] nvarchar(64) NULL;
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20261031014955_AddGoogleId'
)
BEGIN
    EXEC(N'CREATE UNIQUE INDEX [IX_Users_GoogleId] ON [Users] ([GoogleId]) WHERE [GoogleId] IS NOT NULL');
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20261031014955_AddGoogleId'
)
BEGIN
    INSERT INTO [__EFMigrationsHistory] ([MigrationId], [ProductVersion])
    VALUES (N'20261031014955_AddGoogleId', N'10.0.14');
END;

COMMIT;
GO

BEGIN TRANSACTION;
IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20261031042252_AddCommunityRecipes'
)
BEGIN
    ALTER TABLE [Users] ADD [Role] nvarchar(20) NOT NULL DEFAULT N'User';
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20261031042252_AddCommunityRecipes'
)
BEGIN
    ALTER TABLE [Recipes] ADD [AuthorId] int NULL;
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20261031042252_AddCommunityRecipes'
)
BEGIN
    ALTER TABLE [Recipes] ADD [IsDeleted] bit NOT NULL DEFAULT CAST(0 AS bit);
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20261031042252_AddCommunityRecipes'
)
BEGIN
    ALTER TABLE [Recipes] ADD [RejectReason] nvarchar(500) NULL;
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20261031042252_AddCommunityRecipes'
)
BEGIN
    ALTER TABLE [Recipes] ADD [ReviewedAt] datetime2 NULL;
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20261031042252_AddCommunityRecipes'
)
BEGIN
    ALTER TABLE [Recipes] ADD [ReviewedById] int NULL;
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20261031042252_AddCommunityRecipes'
)
BEGIN
    ALTER TABLE [Recipes] ADD [Status] int NOT NULL DEFAULT 1;
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20261031042252_AddCommunityRecipes'
)
BEGIN
    ALTER TABLE [Recipes] ADD [SubmittedAt] datetime2 NULL;
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20261031042252_AddCommunityRecipes'
)
BEGIN
    CREATE INDEX [IX_Recipes_AuthorId_Status] ON [Recipes] ([AuthorId], [Status]);
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20261031042252_AddCommunityRecipes'
)
BEGIN
    CREATE INDEX [IX_Recipes_ReviewedById] ON [Recipes] ([ReviewedById]);
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20261031042252_AddCommunityRecipes'
)
BEGIN
    CREATE INDEX [IX_Recipes_Status_SubmittedAt] ON [Recipes] ([Status], [SubmittedAt]);
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20261031042252_AddCommunityRecipes'
)
BEGIN
    EXEC(N'ALTER TABLE [Recipes] ADD CONSTRAINT [CK_Recipes_Status] CHECK ([Status] BETWEEN 0 AND 2)');
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20261031042252_AddCommunityRecipes'
)
BEGIN
    ALTER TABLE [Recipes] ADD CONSTRAINT [FK_Recipes_Users_AuthorId] FOREIGN KEY ([AuthorId]) REFERENCES [Users] ([Id]) ON DELETE NO ACTION;
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20261031042252_AddCommunityRecipes'
)
BEGIN
    ALTER TABLE [Recipes] ADD CONSTRAINT [FK_Recipes_Users_ReviewedById] FOREIGN KEY ([ReviewedById]) REFERENCES [Users] ([Id]) ON DELETE NO ACTION;
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20261031042252_AddCommunityRecipes'
)
BEGIN
    INSERT INTO [__EFMigrationsHistory] ([MigrationId], [ProductVersion])
    VALUES (N'20261031042252_AddCommunityRecipes', N'10.0.14');
END;

COMMIT;
GO

BEGIN TRANSACTION;
IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20261031050226_DropRecipeStatusDefault'
)
BEGIN
    DECLARE @var nvarchar(max);
    SELECT @var = QUOTENAME([d].[name])
    FROM [sys].[default_constraints] [d]
    INNER JOIN [sys].[columns] [c] ON [d].[parent_column_id] = [c].[column_id] AND [d].[parent_object_id] = [c].[object_id]
    WHERE ([d].[parent_object_id] = OBJECT_ID(N'[Recipes]') AND [c].[name] = N'Status');
    IF @var IS NOT NULL EXEC(N'ALTER TABLE [Recipes] DROP CONSTRAINT ' + @var + ';');
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20261031050226_DropRecipeStatusDefault'
)
BEGIN
    INSERT INTO [__EFMigrationsHistory] ([MigrationId], [ProductVersion])
    VALUES (N'20261031050226_DropRecipeStatusDefault', N'10.0.14');
END;

COMMIT;
GO

BEGIN TRANSACTION;
IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20261031072251_DropRescue'
)
BEGIN
    DROP TABLE [RescueHistory];
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20261031072251_DropRescue'
)
BEGIN
    DROP TABLE [RescueOptions];
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20261031072251_DropRescue'
)
BEGIN
    DROP TABLE [RescueNodes];
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20261031072251_DropRescue'
)
BEGIN
    INSERT INTO [__EFMigrationsHistory] ([MigrationId], [ProductVersion])
    VALUES (N'20261031072251_DropRescue', N'10.0.14');
END;

COMMIT;
GO

BEGIN TRANSACTION;
IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20261031073352_AddRecipeDeletedAt'
)
BEGIN
    ALTER TABLE [Recipes] ADD [DeletedAt] datetime2 NULL;
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20261031073352_AddRecipeDeletedAt'
)
BEGIN
    INSERT INTO [__EFMigrationsHistory] ([MigrationId], [ProductVersion])
    VALUES (N'20261031073352_AddRecipeDeletedAt', N'10.0.14');
END;

COMMIT;
GO

