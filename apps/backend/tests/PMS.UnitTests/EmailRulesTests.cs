using PMS.API.Shared.Validation;

namespace PMS.UnitTests;

public class EmailRulesTests
{
    [Theory]
    [InlineData("sahil@gmail.com")]
    [InlineData("sahil.lad@company.com")]
    [InlineData("sahil@company.co.in")]
    [InlineData("  sahil@gmail.com  ")]
    [InlineData("first-last@acme.co")]
    [InlineData("first_last@acme.co")]
    public void AcceptsValidEmails(string email)
    {
        Assert.True(EmailRules.IsValid(email));
    }

    [Theory]
    [InlineData("sahil@")]
    [InlineData("@gmail.com")]
    [InlineData("sahil@gmail")]
    [InlineData("sahil gmail.com")]
    [InlineData("sahil@.com")]
    [InlineData("")]
    [InlineData("   ")]
    [InlineData("sahil@@gmail.com")]
    [InlineData("sahil+tag@gmail.com")]
    [InlineData("sahil#test@gmail.com")]
    [InlineData("sahil$test@gmail.com")]
    [InlineData("sahil%test@gmail.com")]
    [InlineData("sahil^test@gmail.com")]
    [InlineData("sahil!test@gmail.com")]
    [InlineData("sahil&test@gmail.com")]
    [InlineData("user@comp#any.com")]
    public void RejectsInvalidEmails(string email)
    {
        Assert.False(EmailRules.IsValid(email));
    }

    [Fact]
    public void Normalize_TrimsWhitespace()
    {
        Assert.Equal("sahil@gmail.com", EmailRules.Normalize("  sahil@gmail.com  "));
    }
}
