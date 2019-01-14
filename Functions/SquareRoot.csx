#r "Newtonsoft.Json"

using System.Net;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Primitives;
using Newtonsoft.Json;

public static async Task<IActionResult> Run(HttpRequest req, ILogger log)
{
    log.LogInformation("C# HTTP trigger function processed a request.");
    string a = req.Query["a"];

    log.LogInformation(a);

    if(string.IsNullOrEmpty(a)){
        return new BadRequestObjectResult("Bad parameter - missing");
    }
    if(!double.TryParse(a, out double number)){
        return new BadRequestObjectResult("Bad parameter - value");
    }
    if(number < 0){
        return new BadRequestObjectResult("Bad parameter - parameter must be positive");
    }

    return new OkObjectResult(new { result = new { value = Math.Sqrt(number)}});
}
