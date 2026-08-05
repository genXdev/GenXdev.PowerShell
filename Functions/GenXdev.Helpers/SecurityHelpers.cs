using System.Net;
using System.Text;

namespace GenXdev.Helpers
{
    public static class SecurityHelper
    {
        public static string SanitizeFileName(string name, bool giveUniqueSuffix = false)
        {
            var invalidChars = Path.GetInvalidPathChars();

            var sb = new StringBuilder(name.Length);

            foreach (var c in name.ToCharArray())
            {
                if (Array.IndexOf(invalidChars, c) >= 0)
                {
                    sb.Append('_');
                }
                else
                    switch (Char.ToLower(c))
                    {
                        case 'a':
                        case 'b':
                        case 'c':
                        case 'd':
                        case 'e':
                        case 'f':
                        case 'g':
                        case 'h':
                        case 'i':
                        case 'j':
                        case 'k':
                        case 'l':
                        case 'm':
                        case 'n':
                        case 'o':
                        case 'p':
                        case 'q':
                        case 'r':
                        case 's':
                        case 't':
                        case 'u':
                        case 'v':
                        case 'w':
                        case 'x':
                        case 'y':
                        case 'z':
                        case '1':
                        case '2':
                        case '3':
                        case '4':
                        case '5':
                        case '6':
                        case '7':
                        case '8':
                        case '9':
                        case '0':
                        case '!':
                        case '@':
                        case '#':
                        case '$':
                        case '&':
                        case '(':
                        case ')':
                        case '_':
                        case '-':
                        case '+':
                        case '=':
                        case '{':
                        case '}':
                        case '[':
                        case ']':
                        case '.':
                        case ',':
                            sb.Append(c);
                            break;
                        default:
                            sb.Append('_');
                            break;
                    }
            }

            if (giveUniqueSuffix)
            {
                sb.Append("_" + ((UInt32)name.Trim().ToLowerInvariant().GetHashCode()).ToString().PadLeft(10, '0'));
            }

            return sb.ToString().Replace("__", "_");
        }

        public static bool IsSafePublicURL(string URL)
        {
            try
            {
                Uri url = new Uri(URL);
                return HostOrIPPublic(url.Host);
            }
            catch
            {
                return false;
            }
        }
        public static bool IsSafePublicURL(Uri URL)
        {
            return HostOrIPPublic(URL.Host);
        }

        public static bool HostOrIPPublic(string HostName)
        {
            bool result = true;
            try
            {
                IPAddress[] addresslist = Dns.GetHostAddresses(HostName.Trim());

                foreach (IPAddress address in addresslist)
                {
                    if (!IsPublicIpAddress(address))
                    {
                        return false;
                    }
                }
            }
            catch
            {
                result = false;
            }

            return result;
        }

        public static async Task<bool> HostOrIPPublicAsync(string HostName)
        {
            bool result = true;
            try
            {
                var addresslist = await Task.Factory.FromAsync<IPAddress[]>(
                    Dns.BeginGetHostAddresses(HostName.Trim(), null, null),
                    Dns.EndGetHostAddresses);

                foreach (IPAddress address in addresslist)
                {
                    if (!IsPublicIpAddress(address))
                    {
                        return false;
                    }
                }
            }
            catch
            {
                result = false;
            }

            return result;
        }

        public static bool IsPublicIpAddress(IPAddress address)
        {
            try
            {
                // (address.AddressFamily == AddressFamily.InterNetwork);

                String[] straryIPAddress = address.ToString().Split(new String[] { "." }, StringSplitOptions.RemoveEmptyEntries);
                int[] iaryIPAddress = new int[] { int.Parse(straryIPAddress[0]), int.Parse(straryIPAddress[1]), int.Parse(straryIPAddress[2]), int.Parse(straryIPAddress[3]) };
                if (iaryIPAddress[0] == 10 ||
                    (iaryIPAddress[0] == 127 && (iaryIPAddress[1] == 0) && (iaryIPAddress[2] == 0) && (iaryIPAddress[3] == 1)) ||
                    (iaryIPAddress[0] == 192 && iaryIPAddress[1] == 168) ||
                    (iaryIPAddress[0] == 172 && (iaryIPAddress[1] >= 16 && iaryIPAddress[1] <= 31))
                   )
                {
                    return false;
                }
            }
            catch
            {
            }

            return true;
        }
    }
}
