namespace GenXdev.Helpers
{

    /// <summary>
    /// Represents a refactor definition containing settings and state for refactoring operations.
    /// </summary>
    public class RefactorDefinition
    {

        /// <summary>
        /// Gets or sets the name of the refactor definition.
        /// </summary>
        public string Name { get; set; }

        /// <summary>
        /// Gets or sets the priority of the refactor definition.
        /// </summary>
        public int Priority { get; set; }

        /// <summary>
        /// Gets or sets the refactor settings.
        /// </summary>
        public RefactorSettings RefactorSettings { get; set; } = new RefactorSettings();

        /// <summary>
        /// Gets or sets the selection settings.
        /// </summary>
        public SelectionSettings SelectionSettings { get; set; } = new SelectionSettings();

        /// <summary>
        /// Gets or sets the list of refactor log items.
        /// </summary>
        public List<RefactorLogItem> Log { get; set; } = new List<RefactorLogItem>();

        /// <summary>
        /// Gets or sets the refactor state.
        /// </summary>
        public RefactorState State { get; set; } = new RefactorState();
    }

    /// <summary>
    /// Contains settings for refactoring operations.
    /// </summary>
    public class RefactorSettings
    {

        /// <summary>
        /// Gets or sets the prompt key.
        /// </summary>
        public string PromptKey { get; set; }

        /// <summary>
        /// Gets or sets the prompt text.
        /// </summary>
        public string Prompt { get; set; }

        /// <summary>
        /// Gets or sets the list of keys to send.
        /// </summary>
        public List<string> KeysToSend { get; set; } = new List<string>();

        /// <summary>
        /// Gets or sets the code value.
        /// </summary>
        public int Code { get; set; } = -1;

        /// <summary>
        /// Gets or sets the Visual Studio value.
        /// </summary>
        public int VisualStudio { get; set; } = -1;
    }

    /// <summary>
    /// Contains settings for selection operations.
    /// </summary>
    public class SelectionSettings
    {

        /// <summary>
        /// Gets or sets the script for selection.
        /// </summary>
        public string Script { get; set; }

        /// <summary>
        /// Gets or sets a value indicating whether to automatically add modified files.
        /// </summary>
        public bool AutoAddModifiedFiles { get; set; }

        /// <summary>
        /// Gets or sets the LLM settings for selection.
        /// </summary>
        public RefactorSelectionLLMSettings LLM { get; set; } = new RefactorSelectionLLMSettings();
    }

    /// <summary>
    /// Contains LLM settings for refactor selection.
    /// </summary>
    public class RefactorSelectionLLMSettings
    {

        /// <summary>
        /// Gets or sets the prompt for the LLM.
        /// </summary>
        public string Prompt { get; set; }

        /// <summary>
        /// Gets or sets the model name.
        /// </summary>
        public string Model { get; set; }

        /// <summary>
        /// Gets or sets the temperature for the LLM.
        /// </summary>
        public double Temperature { get; set; }

        /// <summary>
        /// Gets or sets the TTL in seconds.
        /// </summary>
        public int TTLSeconds { get; set; } = 0;

        /// <summary>
        /// Gets or sets the timeout in seconds for AI operations.
        /// </summary>
        public int TimeoutSeconds { get; set; }

        /// <summary>
        /// Gets or sets the type of LLM query.
        /// </summary>
        public string LLMQueryType { get; set; } = "SimpleIntelligence";

        /// <summary>
        /// Gets or sets a value indicating whether the LLM does not support JSON schema.
        /// </summary>
        public bool NoSupportForJsonSchema { get; set; }

        /// <summary>
        /// Gets or sets a value indicating whether the LLM does not support image uploads.
        /// </summary>
        public bool NoSupportForImageUpload { get; set; }

        /// <summary>
        /// Gets or sets a value indicating whether the LLM does not support tool calls.
        /// </summary>
        public bool NoSupportForToolCalls { get; set; }

        /// <summary>
        /// Gets or sets the API endpoint.
        /// </summary>
        public string ApiEndpoint { get; set; }

        /// <summary>
        /// Gets or sets the API key.
        /// </summary>
        public string ApiKey { get; set; }

        /// <summary>
        /// Gets or sets the list of exposed cmdlets.
        /// </summary>
        public List<ExposedCmdletDefinition> ExposedCmdlets { get; set; } = new List<ExposedCmdletDefinition>();
    }

    /// <summary>
    /// Represents a log item for refactoring operations.
    /// </summary>
    public class RefactorLogItem
    {

        /// <summary>
        /// Gets or sets the timestamp of the log item.
        /// </summary>
        public System.DateTime Timestamp { get; set; } = System.DateTime.UtcNow;

        /// <summary>
        /// Gets or sets the message of the log item.
        /// </summary>
        public string Message { get; set; } = "";
    }

    /// <summary>
    /// Represents the state of a refactoring operation.
    /// </summary>
    public class RefactorState
    {

        /// <summary>
        /// Gets or sets the status of the refactoring.
        /// </summary>
        public string Status { get; set; } = "Definition Created";

        /// <summary>
        /// Gets or sets the last updated timestamp.
        /// </summary>
        public System.DateTime LastUpdated { get; set; } = System.DateTime.UtcNow;

        /// <summary>
        /// Gets or sets the last refactoring timestamp.
        /// </summary>
        public System.DateTime? LastRefactoring { get; set; }

        /// <summary>
        /// Gets or sets the percentage complete.
        /// </summary>
        public int PercentageComplete { get; set; }

        /// <summary>
        /// Gets or sets the refactored index.
        /// </summary>
        public int RefactoredIndex { get; set; } = -1;

        /// <summary>
        /// Gets or sets the selected index.
        /// </summary>
        public int SelectedIndex { get; set; } = -1;

        /// <summary>
        /// Gets or sets the unselected index.
        /// </summary>
        public int UnselectedIndex { get; set; } = -1;

        /// <summary>
        /// Gets or sets the list of selected items.
        /// </summary>
        public List<string> Selected { get; set; } = new List<string>();

        /// <summary>
        /// Gets or sets the list of refactored items.
        /// </summary>
        public List<string> Refactored { get; set; } = new List<string>();

        /// <summary>
        /// Gets or sets the list of unselected items.
        /// </summary>
        public List<string> Unselected { get; set; } = new List<string>();
    }
}
