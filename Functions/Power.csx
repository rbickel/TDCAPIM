#r "Newtonsoft.Json"

using System.Net;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Primitives;
using Newtonsoft.Json;

public static async Task<IActionResult> Run(HttpRequest req, ILogger log)
{
    log.LogInformation("C# HTTP trigger function processed a request.");
    string a = req.Query["a"];
    string b = req.Query["b"];

    log.LogInformation(a);
    log.LogInformation(b);

    if(string.IsNullOrEmpty(a) || string.IsNullOrEmpty(b)){
        return new BadRequestObjectResult("Bad parameters - missing");
    }
    if(!double.TryParse(a, out double number) || !double.TryParse(b, out double power)){
        return new BadRequestObjectResult("Bad parameters - value");
    }

    return new OkObjectResult(new { result = new { value = Math.Pow(number, power)}});

}
