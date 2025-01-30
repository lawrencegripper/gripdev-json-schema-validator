using System;
using System.Collections.Generic;
using System.IO;
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

                var errorDetails = new List<object>();
                foreach (var error in errors)
                {
                    errorDetails.Add(new
                    {
                        Message = error.Message,
                        LineNumber = error.LineNumber,
                        LinePosition = error.LinePosition,
                        Path = error.Path
                    });
                }

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
