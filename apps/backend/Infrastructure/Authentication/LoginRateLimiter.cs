using System.Collections.Concurrent;

namespace PMS.API.Infrastructure.Authentication;

/// <summary>
/// Lightweight in-memory sliding-window rate limiter for authentication endpoints
/// (brute-force mitigation on top of per-account lockout). Per IP address.
/// Replace with a Redis-backed limiter when scaling horizontally.
/// </summary>
public sealed class LoginRateLimiter(TimeSpan window, int maxRequests)
{
    private readonly ConcurrentDictionary<string, Queue<DateTime>> _attempts = new();

    public bool Allow(string key)
    {
        var now = DateTime.UtcNow;
        var queue = _attempts.GetOrAdd(key, _ => new Queue<DateTime>());

        lock (queue)
        {
            while (queue.Count > 0 && now - queue.Peek() > window)
                queue.Dequeue();

            if (queue.Count >= maxRequests)
                return false;

            queue.Enqueue(now);
            return true;
        }
    }

    public void Reset(string key)
    {
        _attempts.TryRemove(key, out _);
    }
}
