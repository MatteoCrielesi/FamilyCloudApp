namespace FamilyCloudApp.Core.Models;

public sealed class UploadTask
{
    public string? LocalPath { get; set; }
    public string? RemotePath { get; set; }
    public long TotalBytes { get; set; }
    public long UploadedBytes { get; set; }
}
