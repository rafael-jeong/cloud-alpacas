public with sharing class SponsorshipPackageLookup {

    @InvocableMethod(
        label='List Sponsorship Packages'
        description='Returns active Sponsorship Package Product2 records with their Standard Price Book unit price.'
    )
    public static List<Result> execute(List<Request> requests) {
        List<PackageInfo> packageList = new List<PackageInfo>();
        for (Product2 p : [
            SELECT Id, Name, ProductCode,
                   (SELECT UnitPrice FROM PricebookEntries WHERE Pricebook2.IsStandard = true AND IsActive = true LIMIT 1)
            FROM Product2
            WHERE RecordType.DeveloperName = 'Sponsorship_Package' AND IsActive = true
            WITH USER_MODE
        ]) {
            PackageInfo info = new PackageInfo();
            info.productId = p.Id;
            info.productName = p.Name;
            info.productCode = p.ProductCode;
            if (!p.PricebookEntries.isEmpty()) {
                info.unitPrice = p.PricebookEntries[0].UnitPrice;
            }
            packageList.add(info);
        }

        List<Result> results = new List<Result>();
        for (Request req : requests) {
            Result r = new Result();
            r.packages = packageList;
            results.add(r);
        }
        return results;
    }

    public class Request {
        // This action takes no real input (always returns the full active list),
        // but InvocableMethod requires a non-empty Request wrapper class.
        @InvocableVariable(
            label='Unused'
            description='This action requires no input - always returns the full active Sponsorship Package list.'
            required=false
        )
        public Boolean unused;
    }

    public class Result {
        @InvocableVariable(label='Sponsorship Packages' description='Active Sponsorship Package Product2 records with Standard Price Book pricing.')
        public List<PackageInfo> packages;
    }

    public class PackageInfo {
        @InvocableVariable(label='Product Id' description='Product2.Id')
        public Id productId;

        @InvocableVariable(label='Product Name' description='Product2.Name')
        public String productName;

        @InvocableVariable(label='Product Code' description='Product2.ProductCode')
        public String productCode;

        @InvocableVariable(label='Unit Price' description='Standard Price Book UnitPrice for this package.')
        public Decimal unitPrice;
    }
}
