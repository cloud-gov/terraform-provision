# WAF Rules Creation and Testing

## Step 1: Implementation

A platform engineer either creates new custom WAF rules, or modifies existing ones, by creating a pull request in GitHub within the cg-provision repository and modifying the elb_uaa.tf file.  This pull request will contain any changes necessary to make or adjust the custom WAF rules.

## Step 2: Review

Once the platform engineer is finished with their implementation of the new/modified custom WAF rules, they submit a pull request for review. Another platform engineer will either review the pull request directly and submit feedback and/or pair with the author of the pull request in a live coding session to walk through the changes and make any adjustments necessary.  Subsequent changes will be committed to the branch associated with the pull request until it is deemed ready to merge, at which point the reviewing platform engineer will formally approve the pull request.  Either the author or the reviewer will then merge the pull request, which will bring the changes into the main repository and trigger a new development environment build and testing cycle within our continuous integration and development pipeline in Concourse.

## Step 3: Testing

When a development build and test cycle is triggered in Concourse, the changes to the Terraform code will be tested and applied strictly within our development environment only.  If the changes pass Terraform’s validation, they will trigger AWS API calls to make the actual custom WAF rule set adjustments and a new Terraform state file will be created and stored.  The new Terraform state file will also trigger BOSH and Cloud Foundry builds, as well as automated testing of the new custom WAF rule sets.  If those automated tests pass, then the platform engineer(s) will take a final look to verify that everything is still functioning properly and accessible within the development environment.

If any of the automated or manual testing yields an issue, steps 1 through 5 are repeated for a new build and test cycle in the development environment until all tests pass and the deployment is 100% successful.

### Testing Details

In order to test that a new WAF rule is working properly, the steps we will either take or automate are the following:

1. Write a failing custom rule test (e.g. we want to block:, https://app.($CLOUD_GOV_ENV)/vulnerableURL, which will return a `403` when the url is successfully blocked.
  1. Test urls and corresponding variables are stored in s3
1. Run our tests and ensure the tests fail (because they don't yet return 403)
1. Create and test the new custom WAF rule (e.g., a RegEx rule: ^\vulnerableURL$) in the WebUI in the dev environment. Once it’s working, remove it.
1. Apply the new or modified rule to the custom WAF rule set in Terraform.
  1. Regex patterns are specified in the corresponding pipeline variable
    1. NOTE: Both the tests and rules will use the same storage backend. If either of them exhausts credhub, then they’ll both move to s3vars.
1. Deploy the changes into the development environment (or whichever environment we’re currently targeting)
1. Ensure the test we created in step 1 now passes. 

## Step 4: Promote to Staging Environment

When all manual and automated tests of the new custom WAF rule sets are complete in the development environment, a platform engineer will manually trigger the build and test cycle of the same changes in the staging environment.  All automated and manual testing from Step 3 is repeated in the staging environment.  If any issue is found, steps 1 and 2 are repeated back through the development environment again until everything is clear to run through in the staging environment.

## Step 5: Promote to Production Environment

When all automated and manual tests are complete in staging and the custom WAF rule set changes are deemed ready for deployment to production, a platform engineer will manually trigger the build and test cycle for the production environment.

Again, the same steps are repeated for testing in production with both automated and manual tests to ensure that everything is working properly and deployed successfully.  If any issue is found, the production environment is immediately rolled back to its previous working state, and the changes undergo further review with steps 1 - 3 repeated in the development environment at first.  When the changes are validated in the development environment again, they will go through another round of testing in the staging environment before being deployed to production again.

When the custom WAF rule sets are verified to be working in production, the deployment is complete and the work is marked as finished in our project planning board.

## Caveats

There are a few things to bear in mind when creating new custom WAF rule sets:

- There is a 1500 WCU (Web ACL Capacity Units) limit by default, and 700 are already used with the default Amazon WAF rule sets.
- We can request an increase with the WCU quota if needed
- Custom WAF rules are not free, so we must pay attention to the pricing so that we stay within our budget: https://aws.amazon.com/waf/pricing/