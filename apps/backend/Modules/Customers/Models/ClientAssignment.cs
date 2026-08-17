using PMS.API.Modules.Users.Models;

namespace PMS.API.Modules.Customers.Models;

/// <summary>
/// Explicit per-user grant of a client. Used for data scoping — e.g. a
/// Senior PM or Engagement Manager sees only assigned clients.
/// </summary>
public class ClientAssignment
{
    public Guid ClientId { get; set; }

    public Client? Client { get; set; }

    public Guid UserId { get; set; }

    public User? User { get; set; }
}
