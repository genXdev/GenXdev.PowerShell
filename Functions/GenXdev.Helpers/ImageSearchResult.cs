using Newtonsoft.Json;
using Newtonsoft.Json.Converters;
using System.Globalization;

#nullable enable

namespace GenXdev.Helpers
{
    /// <summary>
    /// Represents the result of an image search operation, containing metadata, descriptions, and analysis data for an image.
    /// This class encapsulates all information extracted from image processing, including object detection, scene analysis, and metadata.
    /// </summary>
    public partial class ImageSearchResult
    {
        [JsonProperty("description", NullValueHandling = NullValueHandling.Ignore)]
        public ImageSearchResultDescription Description { get; set; } = new ImageSearchResultDescription();

        [JsonProperty("metadata", NullValueHandling = NullValueHandling.Ignore)]
        public ImageSearchResultMetadata Metadata { get; set; } = new ImageSearchResultMetadata();

        [JsonProperty("height", NullValueHandling = NullValueHandling.Ignore)]
        public long Height { get; set; }

        [JsonProperty("objects", NullValueHandling = NullValueHandling.Ignore)]
        public ImageSearchResultObjects Objects { get; set; } = new ImageSearchResultObjects();

        [JsonProperty("keywords", NullValueHandling = NullValueHandling.Ignore)]
        public List<string> Keywords
        {
            get
            {

                if (Description == null) return new List<string>();

                return Description.Keywords;
            }

            set
            {
                if (Description == null) Description = new ImageSearchResultDescription();
                if (value == null) return;

                Description = new ImageSearchResultDescription();

                Description.Keywords = value;
            }
        }

        [JsonProperty("path")]
        public string Path { get; set; } = string.Empty;

        [JsonProperty("scenes", NullValueHandling = NullValueHandling.Ignore)]
        public ImageSearchResultScenes Scenes { get; set; } = new ImageSearchResultScenes();

        [JsonProperty("people", NullValueHandling = NullValueHandling.Ignore)]
        public ImageSearchResultPeople People { get; set; } = new ImageSearchResultPeople();

        [JsonProperty("width", NullValueHandling = NullValueHandling.Ignore)]
        public long Width { get; set; }
    }

    public partial class ImageSearchResultDescription
    {
        [JsonProperty("style_type", NullValueHandling = NullValueHandling.Ignore)]
        public string Style_Type { get; set; } = string.Empty;

        [JsonProperty("short_description", NullValueHandling = NullValueHandling.Ignore)]
        public string Short_Description { get; set; } = string.Empty;

        [JsonProperty("has_nudity", NullValueHandling = NullValueHandling.Ignore)]
        public bool? Has_Nudity { get; set; } = null;

        [JsonProperty("keywords", NullValueHandling = NullValueHandling.Ignore)]
        public List<string> Keywords { get; set; } = new List<string>();

        [JsonProperty("long_description", NullValueHandling = NullValueHandling.Ignore)]
        public string Long_Description { get; set; } = string.Empty;

        [JsonProperty("picture_type", NullValueHandling = NullValueHandling.Ignore)]
        public string Picture_Type { get; set; } = string.Empty;

        [JsonProperty("has_explicit_content", NullValueHandling = NullValueHandling.Ignore)]
        public bool? Has_Explicit_Content { get; set; } = null;

        [JsonProperty("overall_mood_of_image", NullValueHandling = NullValueHandling.Ignore)]
        public string Overall_MoodOf_Image { get; set; } = string.Empty;
    }

    public partial class ImageSearchResultMetadata
    {
        [JsonProperty("GPS", NullValueHandling = NullValueHandling.Ignore)]
        public ImageSearchResultGps Gps { get; set; } = new ImageSearchResultGps();

        [JsonProperty("Basic", NullValueHandling = NullValueHandling.Ignore)]
        public ImageSearchResultBasic Basic { get; set; } = new ImageSearchResultBasic();

        [JsonProperty("Author", NullValueHandling = NullValueHandling.Ignore)]
        public ImageSearchResultAuthor Author { get; set; } = new ImageSearchResultAuthor();

        [JsonProperty("Exposure", NullValueHandling = NullValueHandling.Ignore)]
        public ImageSearchResultExposure Exposure { get; set; } = new ImageSearchResultExposure();

        [JsonProperty("DateTime", NullValueHandling = NullValueHandling.Ignore)]
        public ImageSearchResultDateTime DateTime { get; set; } = new ImageSearchResultDateTime();

        [JsonProperty("Other", NullValueHandling = NullValueHandling.Ignore)]
        public ImageSearchResultOther Other { get; set; } = new ImageSearchResultOther();

        [JsonProperty("Camera", NullValueHandling = NullValueHandling.Ignore)]
        public ImageSearchResultCamera Camera { get; set; } = new ImageSearchResultCamera();
    }

    // GPS: latitude, longitude, etc.
    public partial class ImageSearchResultGps
    {
        [JsonProperty("Latitude", NullValueHandling = NullValueHandling.Ignore)]
        public double? Latitude { get; set; }

        [JsonProperty("Longitude", NullValueHandling = NullValueHandling.Ignore)]
        public double? Longitude { get; set; }

        [JsonProperty("Altitude", NullValueHandling = NullValueHandling.Ignore)]
        public double? Altitude { get; set; }

        [JsonProperty("LatitudeDMS", NullValueHandling = NullValueHandling.Ignore)]
        public string LatitudeDMS { get; set; } = string.Empty;

        [JsonProperty("LongitudeDMS", NullValueHandling = NullValueHandling.Ignore)]
        public string LongitudeDMS { get; set; } = string.Empty;

        [JsonProperty("LatitudeError", NullValueHandling = NullValueHandling.Ignore)]
        public string LatitudeError { get; set; } = string.Empty;

        [JsonProperty("LongitudeError", NullValueHandling = NullValueHandling.Ignore)]
        public string LongitudeError { get; set; } = string.Empty;

        [JsonProperty("AltitudeError", NullValueHandling = NullValueHandling.Ignore)]
        public string AltitudeError { get; set; } = string.Empty;
    }


    // Author: Contains artist, copyright, etc. (string properties, may be empty)
    public partial class ImageSearchResultAuthor
    {
        [JsonProperty("Artist", NullValueHandling = NullValueHandling.Ignore)]
        public string Artist { get; set; } = string.Empty;

        [JsonProperty("Copyright", NullValueHandling = NullValueHandling.Ignore)]
        public string Copyright { get; set; } = string.Empty;
    }

    // Basic: dimensions, format, etc.
    public partial class ImageSearchResultBasic
    {
        [JsonProperty("Width", NullValueHandling = NullValueHandling.Ignore)]
        public long Width { get; set; }

        [JsonProperty("Height", NullValueHandling = NullValueHandling.Ignore)]
        public long Height { get; set; }

        [JsonProperty("PixelFormat", NullValueHandling = NullValueHandling.Ignore)]
        public string PixelFormat { get; set; } = string.Empty;

        [JsonProperty("Format", NullValueHandling = NullValueHandling.Ignore)]
        public string Format { get; set; } = string.Empty;

        [JsonProperty("HorizontalResolution", NullValueHandling = NullValueHandling.Ignore)]
        public double HorizontalResolution { get; set; }

        [JsonProperty("VerticalResolution", NullValueHandling = NullValueHandling.Ignore)]
        public double VerticalResolution { get; set; }

        [JsonProperty("FileSizeBytes", NullValueHandling = NullValueHandling.Ignore)]
        public long FileSizeBytes { get; set; }

        [JsonProperty("FileName", NullValueHandling = NullValueHandling.Ignore)]
        public string FileName { get; set; } = string.Empty;

        [JsonProperty("FileExtension", NullValueHandling = NullValueHandling.Ignore)]
        public string FileExtension { get; set; } = string.Empty;
    }

    // Exposure: aperture, shutter speed, ISO, etc.
    public partial class ImageSearchResultExposure
    {
        [JsonProperty("FNumber", NullValueHandling = NullValueHandling.Ignore)]
        public double? FNumber { get; set; }

        [JsonProperty("ExposureTime", NullValueHandling = NullValueHandling.Ignore)]
        public double? ExposureTime { get; set; }

        [JsonProperty("ISOSpeedRatings", NullValueHandling = NullValueHandling.Ignore)]
        public int? ISOSpeedRatings { get; set; }

        [JsonProperty("FocalLength", NullValueHandling = NullValueHandling.Ignore)]
        public double? FocalLength { get; set; }

        [JsonProperty("ExposureProgram", NullValueHandling = NullValueHandling.Ignore)]
        public int? ExposureProgram { get; set; }

        [JsonProperty("MeteringMode", NullValueHandling = NullValueHandling.Ignore)]
        public int? MeteringMode { get; set; }

        [JsonProperty("Flash", NullValueHandling = NullValueHandling.Ignore)]
        public int? Flash { get; set; }
    }

    // Camera: make, model, etc.
    public partial class ImageSearchResultCamera
    {
        [JsonProperty("Make", NullValueHandling = NullValueHandling.Ignore)]
        public string Make { get; set; } = string.Empty;

        [JsonProperty("Model", NullValueHandling = NullValueHandling.Ignore)]
        public string Model { get; set; } = string.Empty;

        [JsonProperty("Software", NullValueHandling = NullValueHandling.Ignore)]
        public string Software { get; set; } = string.Empty;
    }

    // DateTime: when taken, modified, etc.
    public partial class ImageSearchResultDateTime
    {
        [JsonProperty("DateTimeOriginal", NullValueHandling = NullValueHandling.Ignore)]
        public string DateTimeOriginal { get; set; } = String.Empty;

        [JsonProperty("DateTimeDigitized", NullValueHandling = NullValueHandling.Ignore)]
        public string DateTimeDigitized { get; set; } = String.Empty;
    }

    // GPS: latitude, longitude, etc.
    public partial class ImageSearchResultGPS
    {
        [JsonProperty("Latitude", NullValueHandling = NullValueHandling.Ignore)]
        public double? Latitude { get; set; }

        [JsonProperty("Longitude", NullValueHandling = NullValueHandling.Ignore)]
        public double? Longitude { get; set; }

        [JsonProperty("Altitude", NullValueHandling = NullValueHandling.Ignore)]
        public double? Altitude { get; set; }

        [JsonProperty("LatitudeDMS", NullValueHandling = NullValueHandling.Ignore)]
        public string LatitudeDMS { get; set; } = string.Empty;

        [JsonProperty("LongitudeDMS", NullValueHandling = NullValueHandling.Ignore)]
        public string LongitudeDMS { get; set; } = string.Empty;
    }

    // Other: software, comments, errors, etc. (dynamic, so use dictionary)
    public partial class ImageSearchResultOther
    {
        [JsonProperty("Software", NullValueHandling = NullValueHandling.Ignore)]
        public string Software { get; set; } = string.Empty;

        [JsonProperty("ColorSpace", NullValueHandling = NullValueHandling.Ignore)]
        public string ColorSpace { get; set; } = string.Empty;

        [JsonProperty("ResolutionUnit", NullValueHandling = NullValueHandling.Ignore)]
        public string ResolutionUnit { get; set; } = string.Empty;
    }

    public partial class ImageSearchResultObjects
    {
        [JsonProperty("objects", NullValueHandling = NullValueHandling.Ignore)]
        public List<ImageSearchResultObject> objects { get; set; } = new List<ImageSearchResultObject>();

        [JsonProperty("object_counts", NullValueHandling = NullValueHandling.Ignore)]
        public Dictionary<string, int> object_counts { get; set; } = new Dictionary<string, int>();

        [JsonProperty("count", NullValueHandling = NullValueHandling.Ignore)]
        public long Count { get; set; }
    }

    public partial class ImageSearchResultFacePrediction
    {
        [JsonProperty("confidence", NullValueHandling = NullValueHandling.Ignore)]
        public double Confidence { get; set; }

        [JsonProperty("y_min", NullValueHandling = NullValueHandling.Ignore)]
        public long Y_Min { get; set; }

        [JsonProperty("x_min", NullValueHandling = NullValueHandling.Ignore)]
        public long X_Min { get; set; }

        [JsonProperty("y_max", NullValueHandling = NullValueHandling.Ignore)]
        public long Y_Max { get; set; }

        [JsonProperty("x_max", NullValueHandling = NullValueHandling.Ignore)]
        public long X_Max { get; set; }

        [JsonProperty("userid", NullValueHandling = NullValueHandling.Ignore)]
        public string UserId { get; set; } = string.Empty;
    }

    public partial class ImageSearchResultObject
    {
        [JsonProperty("confidence", NullValueHandling = NullValueHandling.Ignore)]
        public double Confidence { get; set; }

        [JsonProperty("label", NullValueHandling = NullValueHandling.Ignore)]
        public string Label { get; set; } = string.Empty;

        [JsonProperty("y_min", NullValueHandling = NullValueHandling.Ignore)]
        public long Y_Min { get; set; }

        [JsonProperty("x_min", NullValueHandling = NullValueHandling.Ignore)]
        public long X_Min { get; set; }

        [JsonProperty("y_max", NullValueHandling = NullValueHandling.Ignore)]
        public long Y_Max { get; set; }

        [JsonProperty("x_max", NullValueHandling = NullValueHandling.Ignore)]
        public long X_Max { get; set; }
    }

    public partial class ImageSearchResultPeople
    {
        [JsonProperty("faces", NullValueHandling = NullValueHandling.Ignore)]
        public List<string> Faces { get; set; } = new List<string>();

        [JsonProperty("success", NullValueHandling = NullValueHandling.Ignore)]
        public bool Success { get; set; }

        [JsonProperty("count", NullValueHandling = NullValueHandling.Ignore)]
        public long Count { get; set; }

        [JsonProperty("predictions", NullValueHandling = NullValueHandling.Ignore)]
        public List<ImageSearchResultFacePrediction> Predictions { get; set; } = new List<ImageSearchResultFacePrediction>();
    }

    public partial class ImageSearchResultScenes
    {
        [JsonProperty("confidence", NullValueHandling = NullValueHandling.Ignore)]
        public double Confidence { get; set; }

        [JsonProperty("success", NullValueHandling = NullValueHandling.Ignore)]
        public bool Success { get; set; }

        [JsonProperty("label", NullValueHandling = NullValueHandling.Ignore)]
        public string Label { get; set; } = string.Empty;

        [JsonProperty("scene", NullValueHandling = NullValueHandling.Ignore)]
        public string Scene { get; set; } = string.Empty;

        [JsonProperty("confidence_percentage", NullValueHandling = NullValueHandling.Ignore)]
        public double Confidence_Percentage { get; set; }
    }

    public partial class ImageSearchResult
    {
        public static ImageSearchResult FromJson(string json) => JsonConvert.DeserializeObject<ImageSearchResult>(json, GenXdev.Helpers.ImageSearchResultConverter.Settings)!;
    }

    public static class ImageSearchResultSerialize
    {
        public static string ToJson(this ImageSearchResult self) => JsonConvert.SerializeObject(self, GenXdev.Helpers.ImageSearchResultConverter.Settings);
        public static string ToJson(IEnumerable<ImageSearchResult> container) => JsonConvert.SerializeObject(container, GenXdev.Helpers.ImageSearchResultConverter.Settings);
    }

    internal static class ImageSearchResultConverter
    {
        public static readonly JsonSerializerSettings Settings = new JsonSerializerSettings
        {
            MetadataPropertyHandling = MetadataPropertyHandling.Ignore,
            MissingMemberHandling = MissingMemberHandling.Ignore,
            DateParseHandling = DateParseHandling.None,
            Converters =
            {
                new IsoDateTimeConverter { DateTimeStyles = DateTimeStyles.AssumeUniversal }
            },
        };
    }
}
