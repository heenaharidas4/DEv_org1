//Generated by wsdl2apex

public class tempuriOrg {
    public class HelloWorld_element {
        public String a;
        public String b;
        private String[] a_type_info = new String[]{'a','http://tempuri.org/',null,'0','1','false'};
        private String[] b_type_info = new String[]{'b','http://tempuri.org/',null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://tempuri.org/','true','false'};
        private String[] field_order_type_info = new String[]{'a','b'};
    }
    public class HelloWorldResponse_element {
        public String HelloWorldResult;
        private String[] HelloWorldResult_type_info = new String[]{'HelloWorldResult','http://tempuri.org/',null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://tempuri.org/','true','false'};
        private String[] field_order_type_info = new String[]{'HelloWorldResult'};
    }
    public class Service1Soap {
        public String endpoint_x = 'https://qa-esb-sfdc-1697250918.us-east-1.elb.amazonaws.com/EchoService/Service1.asmx';
        public Map<String,String> inputHttpHeaders_x;
        public Map<String,String> outputHttpHeaders_x;
        public String clientCertName_x;
        public String clientCert_x;
        public String clientCertPasswd_x;
        public Integer timeout_x;
        private String[] ns_map_type_info = new String[]{'http://tempuri.org/', 'tempuriOrg'};
        public String HelloWorld(String a,String b) {
            tempuriOrg.HelloWorld_element request_x = new tempuriOrg.HelloWorld_element();
            tempuriOrg.HelloWorldResponse_element response_x;
            request_x.a = a;
            request_x.b = b;
            Map<String, tempuriOrg.HelloWorldResponse_element> response_map_x = new Map<String, tempuriOrg.HelloWorldResponse_element>();
            response_map_x.put('response_x', response_x);
            WebServiceCallout.invoke(
              this,
              request_x,
              response_map_x,
              new String[]{endpoint_x,
              'http://tempuri.org/HelloWorld',
              'http://tempuri.org/',
              'HelloWorld',
              'http://tempuri.org/',
              'HelloWorldResponse',
              'tempuriOrg.HelloWorldResponse_element'}
            );
            response_x = response_map_x.get('response_x');
            return response_x.HelloWorldResult;
        }
    }
}