using PMS.API.Shared.Common.Wrappers;

namespace PMS.UnitTests;

public class PagedResultTests
{
    [Fact]
    public void TotalPages_RoundsUp()
    {
        var result = new PagedResult<string>(["a", "b", "c"], Page: 1, PerPage: 2, Total: 3);

        Assert.Equal(2, result.TotalPages);
    }

    [Fact]
    public void TotalPages_ZeroWhenPerPageZero()
    {
        var result = new PagedResult<string>([], Page: 1, PerPage: 0, Total: 10);

        Assert.Equal(0, result.TotalPages);
    }
}
