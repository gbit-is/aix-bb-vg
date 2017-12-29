# AIX-BB-VG

The Xymon/Hobbit/BB monitoring system is still widely used. Some people use it with AIX
Those who have a large AIX infrastructure might want to monitor the status of the VG's
This tool reports the percentage of used space within a VG with the following logic


```
                                                                        / Yes ------ Red flag
                           / Yes  ---- Is total free less then minsize ?
 ----Red threshold reached ?                   /yes, yelllow flag       \  No ------  Yellow flag
                           \ No  - Yel thre reached ?                          / Yes, green flag
                                                   \ no --- Green flag there ?
                                                                              \ No, Error state reached. Red flag
```

## Getting Started


### Prerequisites

This requires only the infrastructure for which it used for, AIX server with a Xymon client and a Xymon Server
And most likely a decent understanding of the Xymon enviroment
The tool uses only standard shell utilities

### Install

Place bb-vg.sh in $XYMON_HOME/
chown it to the XYMON user and make it executable
Define the test in clientlaunch.cfg

### Configuring

Monitor specific VG's:
In the first few lines there is a definition for the variable "vgs"
By using grep and negative greps the list is filtered out
There is a line, commented out which provides an example

Change the alert thresholds:
The thresholds are specified in 3 variables

redthresh: 	Should be the highest, the percentage in which a VG is considered red 
yelthresh:	Should be lower then red, the percentage in which a VG is considered yellow
minsize:  	Specified in GB's. In extremly large VG's, a VG might be in 95% but still have N gigabytes free.
	   	if a test is flagged as red, due to percentage but it has more GB's free then specified here
		then the test will be flagged as green

Adjusting the test timeout:

At the end of the file the lines that specify sending data to Xymon that can be adjusted

```
$bb "status+7h $(hostname).vg red $(echo $(hostname)   $(date))  $(cat $tmp)"
```

Change the "+7h" to a value of your choice. I run it every 6 hours and keep an extra hour
so the test doesn't timeout by being so close to the timeout



## Authors

* **Gbit** - [Gbit-is](https://github.com/gbit-is)


## License

This project is licensed under the MIT License
