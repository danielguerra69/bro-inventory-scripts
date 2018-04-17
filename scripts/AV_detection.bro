# Script to detect the AV software running on the clients/end-points,
# by analyzing DNS requests to the corresponding AV servers for updates.

##Mcafee##
# Mcafee GTI File Reputation accesses an online master database to determine whether a file is suspicious. 
# GTI File Reputation queries can be recognized because they are on sub domains of avqs.mcafee.com or avts.mcafee.com.
# By determining the src_ip making the queries to GTI DB for suspicious file, one can find out if they are running Mcafee VS.
# Following script determines the Mcafee AV by looking at the DNS queries for those sub-domains.

##MalwareBytes##
# The DNS keystone.mwbsys.com is used for verification of license keys by the various Malwarebytes apps.

##AVAST##
# AVAST uses Real Site Protection, having own DNS servers, and using ff.avast.com as their streaming server to push updates to the clients

##Sophos##
# Sophos uses Sophos Extensible List (SXL) for providing Live protection

##Qihu##
# Qihu is a Chinese AV solution


@load base/frameworks/software
@load base/protocols/dns

module AV;

    export {
        redef enum Software::Type += {
        ## Identifier for AV software
            MCAFEE,
            MALWAREBYTES,
            AVAST,
            SOPHOS,
            QIHU,
        };

        type Software::name_and_version: record {
                name   : string;
                version: Software::Version;
        };

      }

event DNS::log_dns (rec: DNS::Info) &priority=5
    {
        local result: Software::name_and_version;
        
        if ( /avts.mcafee.com/ in rec$query )
        {   
            result$name = "Mcafee GTI";
            result$version$addl = "Probably VSCore 14.4.0.354.17 or later";
            Software::found(rec$id, [$version=result$version, $name=result$name, $host=rec$id$orig_h, $software_type=MCAFEE,$unparsed_version=rec$query]);   
        }
        
        if ( /avqs.mcafee.com/ in rec$query )
        {   
            result$name = "Mcafee GTI";
            result$version$addl = "Probably GTI Proxy or Othe Mcafee Entp. product";
            Software::found(rec$id, [$version=result$version, $name=result$name, $host=rec$id$orig_h, $software_type=MCAFEE,$unparsed_version=rec$query]);   
        }
        
        if ( /keystone.mwbsys.com/ in rec$query )
        {   
            result$name = "MalwareBytes";
            Software::found(rec$id, [$name=result$name, $host=rec$id$orig_h, $software_type=MALWAREBYTES,$unparsed_version=rec$query]);   
        }
        
        if ( /sophosxl.net/ in rec$query )
        {   
            result$name = "Sophos";
            Software::found(rec$id, [$name=result$name, $host=rec$id$orig_h, $software_type=SOPHOS,$unparsed_version=rec$query]);   
        }
        
        if ( /ff.avast.com/ in rec$query )
        {   
            result$name = "Avast";
            Software::found(rec$id, [$name=result$name, $host=rec$id$orig_h, $software_type=AVAST,$unparsed_version=rec$query]);   
        }
        
    }
event HTTP::log_http(rec: HTTP::Info) &priority=10
{
  if(rec$method == "POST" && /conf.f.360.cn/ in rec$host)
  {
      result$name = "Qihu";
      Software::found(rec$id, [$name=result$name, $host=rec$id$orig_h, $software_type=QIHU]);
      
  }

}




