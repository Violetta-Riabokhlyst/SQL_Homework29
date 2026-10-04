class Program
{
    static async Task Main()
    {
        try
        {
            string apiKey = GetApiKey();

            Console.Write("Enter movie title: ");
            string movieName = Console.ReadLine();

            if (string.IsNullOrWhiteSpace(movieName))
            {
                Console.WriteLine("Movie title cannot be empty.");
                return;
            }

            using (HttpClient client = new HttpClient())
            {
                string url = "https://api.themoviedb.org/3/search/movie"
                    + "?api_key=" + apiKey
                    + "&query=" + Uri.EscapeDataString(movieName)
                    + "&language=en-US";

                HttpResponseMessage response = await client.GetAsync(url);

                if (response.IsSuccessStatusCode)
                {
                    string json = await response.Content.ReadAsStringAsync();

                    MovieSearchResult result =
                        JsonSerializer.Deserialize<MovieSearchResult>(json);

                    if (result != null && result.Results.Count > 0)
                    {
                        Movie movie = result.Results[0];

                        Console.WriteLine();
                        Console.WriteLine("Movie information:");
                        Console.WriteLine("Title: " + movie.Title);
                        Console.WriteLine("Original title: " + movie.OriginalTitle);
                        Console.WriteLine("Release date: " + movie.ReleaseDate);
                        Console.WriteLine("Rating: " + movie.VoteAverage);
                        Console.WriteLine("Overview: " + movie.Overview);
                    }
                    else
                    {
                        Console.WriteLine("Movie not found.");
                    }
                }
                else
                {
                    Console.WriteLine("Error: " + response.StatusCode);
                    Console.WriteLine("Check your API key or internet connection.");
                }
            }
        }
        catch (HttpRequestException)
        {
            Console.WriteLine("Error: no internet connection.");
        }
        catch (Exception ex)
        {
            Console.WriteLine("Error: " + ex.Message);
        }
    }

    static string GetApiKey()
    {
        IConfiguration configuration = new ConfigurationBuilder()
            .SetBasePath(AppContext.BaseDirectory)
            .AddJsonFile("appsettings.json")
            .Build();

        string apiKey = configuration["MovieApi:ApiKey"];

        if (string.IsNullOrWhiteSpace(apiKey))
        {
            throw new Exception("API key was not found.");
        }

        return apiKey;
    }
}

public class MovieSearchResult
{
    public List<Movie> Results { get; set; }
}

public class Movie
{
    public string Title { get; set; }
    public string OriginalTitle { get; set; }
    public string ReleaseDate { get; set; }
    public double VoteAverage { get; set; }
    public string Overview { get; set; }
}