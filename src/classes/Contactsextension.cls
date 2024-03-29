/**
* @author Matias Menafra
* @createdDate 03/08/2010
*/
public with sharing class Contactsextension{

    private final Integer MAX_SIZE          = 131072; // 128Kb
    private final Integer MAX_LENGTH_NAME   = 71;
    private final String  ERROR_NO_SAVE     = 'Please select a file to upload and try again.';
    private final String  ERROR_IMG_TYPE    = 'The image must be .jpg, .gif or .png';   

    
    private Set<String> imagesTypes         = new Set<String> {'image/jpeg', 'image/pjpeg', 'image/png', 'image/x-png', 'image/gif'};
    private Set<String> notAllowedTypes     = new Set<String> {'application/octet-stream'};
    
    public Attachment   newAttach           { set; get; }
    public Attachment   file                { set; get; }
    private String      parentId            { set; get; }
    public String       postAction          { set; get; }
    public String       error               { set; get; }
    public Boolean      hasPicture          { set; get; }
    
    /**
    * Constructor
    */ 
    public Contactsextension( ApexPages.StandardController stdController ){
        
        this.parentId       = stdController.getId();
        this.hasPicture     = false;
        this.newAttach      = new Attachment();
        this.error          = '';
        
        List<Attachment> attList = [ Select ParentId, Name, Id, ContentType, BodyLength From Attachment where ParentId =: this.parentId and name = 'Account Picture' limit 1];
        if( attList.size() > 0 ){
            this.file               = attList.get( 0 );
            this.hasPicture         = true;
        }
    }
    
    /**
    * Upload action, store the file or replace if exists
    * @return thePage
    */
    public PageReference uploadAction(){
        
        PageReference thePage = new PageReference( '/'+ parentId );
        thePage.setRedirect( true );
        if( this.validate() ){
            return ( this.saveCurrentPicture() ) ? thePage : null;
        }
        else{
            this.newAttach = new Attachment();
            return null;
        }
    }
    
    
    /**
    * Save the New Attachment as Account Picture
    * @return : boolean
    */
    public Boolean saveCurrentPicture(){
        Savepoint sp = Database.setSavepoint();
        try{
            delete [ Select Id From Attachment where ParentId =: this.parentId and name = 'Account Picture' limit 1 ];
            this.newAttach.parentId = this.parentId;
            this.newAttach.name = 'Account Picture';
            insert this.newAttach;
            return true;
        } 
        catch( Exception e ){
            this.error += ERROR_NO_SAVE+'<br/>';
            Database.rollback( sp );
            return false;
        }
    }
    
    
    /**
    * Detele action, delete the curren image
    * @return thePage
    */
    public PageReference deleteAction(){
        
        PageReference thePage = new PageReference( '/'+ parentId );
        thePage.setRedirect( true );
        delete this.file;
        return thePage;
    }
    
    /**
    * Run all verification for the file to upload
    * @return ret
    */
    private Boolean validate(){
        Boolean ret = true;
        this.error = '';
        if( !imagesTypes.contains( newAttach.ContentType ) ){
            this.error += ERROR_IMG_TYPE+'<br/>';
            ret = false;
        }
        return ret;
    }
    
    /**
    * Cancel action
    * @return thePage a page reference
    */
    public PageReference cancel(){
        PageReference thePage = new PageReference( '/'+ parentId );
        thePage.setRedirect( true );
        return thePage;
    }
    
    /**
    * Test cases for rigth image types and a wrong type
    */
    public static testMethod void testImageTypes(){
        TestUtilities tu = TestUtilities.generateTest();
        
        ApexPages.StandardController sc;
        Contactsextension cTest;
        
        Account myAccount = tu.aAcc;
    
        List<String> types = new List<String>{'image/jpeg', 'image/pjpeg', 'image/png', 'image/x-png', 'image/gif'};
    
        Attachment tempAtt = new Attachment();
        
        Test.startTest();
            for( String aType: types ){
                sc = new ApexPages.StandardController(myAccount);
                cTest = new Contactsextension( sc );
                cTest.newAttach.Name = 'Picture-' + sc.getId();
                cTest.newAttach.Body = Blob.valueOf('String');
                cTest.newAttach.ContentType = aType;
                cTest.uploadAction();
                
                cTest.newAttach.Body = Blob.valueOf('String');
                
                System.assert( cTest.newAttach.name == 'Account Picture', 'Name not equals' );
                System.assert( cTest.newAttach.ContentType == aType, 'Types not equals' );
                        
            }

            sc = new ApexPages.StandardController(myAccount);
            cTest = new Contactsextension( sc );
            cTest.newAttach.Name = 'Picture-' + sc.getId();
            cTest.newAttach.Body = Blob.valueOf('String');
            cTest.newAttach.ContentType = 'image/YYY';
            cTest.uploadAction();
            System.assert( cTest.error == 'The image must be .jpg, .gif or .png<br/>', 'Error in error message.' + cTest.error);

            cTest = new Contactsextension( sc );
            cTest.uploadAction();
            
        Test.stopTest();
    } 
    
    /**
    *Test upload picture with no picture at the start.
    *
    */
    public static testMethod void testNoPicture(){
        TestUtilities tu = TestUtilities.generateTest();
        
        Test.startTest();
        ApexPages.StandardController sc = new ApexPages.StandardController( tu.aAcc );
        Contactsextension cTest = new Contactsextension( sc );
        cTest.newAttach.Name = 'Picture-' + sc.getId();
        cTest.newAttach.Body = Blob.valueOf('String');
        cTest.newAttach.ContentType = 'image/jpeg';
        cTest.uploadAction();

        Attachment attUploaded = [ SELECT name, parentId, body, ContentType FROM Attachment WHERE parentId =: sc.getId() AND name = 'Account Picture'];
        System.assert( attUploaded != null, 'No attachment uploaded.' );
        System.assert( attUploaded.name == 'Account Picture', 'Name not equals.' );
        System.assert( attUploaded.Body.toString() == Blob.valueOf('String').toString(), 'Bodys not equals.' );
        System.assert( attUploaded.ContentType == 'image/jpeg', 'Types not equals.' );

        
        // Replace string
        sc = new ApexPages.StandardController( tu.aAcc );
        cTest = new Contactsextension( sc );
        cTest.newAttach.Name = 'Picture-' + sc.getId();
        cTest.newAttach.Body = Blob.valueOf('Other String For Replacement');
        cTest.newAttach.ContentType = 'image/png';
        cTest.uploadAction();
        
        attUploaded = [ SELECT name, parentId, body, ContentType FROM Attachment WHERE parentId =: sc.getId() AND name = 'Account Picture'];
        System.assert( attUploaded != null, 'No attachment uploaded.' );
        System.assert( attUploaded.name == 'Account Picture', 'Name not equals.' );
        System.assert( attUploaded.Body.toString() == Blob.valueOf('Other String For Replacement').toString(), 'Bodys not equals.' );
        System.assert( attUploaded.ContentType == 'image/png', 'Types not equals.' );
        
        
        Id stroringAttIdForRetreve = cTest.newAttach.id;
        cTest = new Contactsextension( sc );
        cTest.deleteAction();
        List<Attachment> attUploadedList = [ SELECT id FROM Attachment WHERE id =: stroringAttIdForRetreve ];

        System.assert( attUploadedList.size() == 0, 'Attachment not deleted !!!' );
        
        Test.stopTest();    
    }
    
    /**
    * Code coverage for cancel action
    */
    public static testMethod void testCancelAction(){
        TestUtilities tu = TestUtilities.generateTest();
        
        Test.startTest();
            ApexPages.StandardController sc = new ApexPages.StandardController( tu.aAcc );
            Contactsextension cTest = new Contactsextension( sc );
            cTest.cancel();         
            System.assert( cTest.cancel() != null, 'Some error occurs with PageReference Method is called' );
        Test.stopTest();
    }
}