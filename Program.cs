using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using Newtonsoft.Json.Linq;
using Newtonsoft.Json.Schema;

namespace GripDevJsonSchemaValidator
{
    class Program
    {
        static void Main(string[] args)
        {
            if (args.Length != 2)
            {
                Console.WriteLine("Usage: GripDevJsonSchemaValidator <schema-file> <json-file>");
                return;
            }

            string schemaFile = args[0];
            string jsonFile = args[1];

            try
            {
                string schemaContent = File.ReadAllText(schemaFile);
                string jsonContent = File.ReadAllText(jsonFile);

                JSchema schema = JSchema.Parse(schemaContent);
                JToken json = JToken.Parse(jsonContent);
                IList<ValidationError> errors;
                bool valid = json.IsValid(schema, out errors);

                var errorDetails = errors?.Select(error =>
                {
                    string errorMessage = $"\n❌ Error Details:\n";
                    errorMessage += $"   └─ Message: {error.Message}\n";
                    errorMessage += $"   └─ Location: Line {error.LineNumber}, Position {error.LinePosition}\n";
                    errorMessage += $"   └─ Path: {error.Path}\n";
                    errorMessage += $"   └─ Value: {error.Value}";

                    if (error.ChildErrors?.Any() == true)
                    {
                        errorMessage += "\n   └─ Related Issues:";
                        foreach (var childError in error.ChildErrors)
                        {
                            errorMessage += $"\n      ↳ {childError.Message}";
                        }
                    }

                    return new
                    {
                        Message = error.Message,
                        UserMessage = errorMessage,
                        LineNumber = error.LineNumber,
                        LinePosition = error.LinePosition,
                        Path = error.Path,
                        Value = error.Value,
                        Schema = error.Schema,
                        SchemaId = error.SchemaId,
                        ErrorType = error.ErrorType,
                        ChildErrors = error.ChildErrors
                    };
                }).ToList();

                var result = new
                {
                    Valid = valid,
                    Errors = errorDetails
                };

                string output = JToken.FromObject(result).ToString();
                Console.WriteLine(output);
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Error: {ex.Message}");
            }
        }
    }
}
