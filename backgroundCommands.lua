ckground_timers = {}                                                             
                                                                                  
function run_background(cmd,funtocall)                                             
   local r = io.popen("mktemp")                                                   
   local logfile = r:read("*line")                                                
   r:close()                                                                      
                                                                                  
   cmdstr = cmd .. " &> " .. logfile .. " & "                                     
   local cmdf = io.popen(cmdstr)                                                  
   cmdf:close()                                                                   
   background_timers[cmd] = {                                                     
       file  = logfile,                                                           
       timer = timer{timeout=1}                                                   
   }                                                                              
   background_timers[cmd].timer:add_signal("timeout",function()                   
       local cmdf = io.popen("pgrep -f '" .. cmd .. "'")                          
       local s = cmdf:read("*all")                                                
       cmdf:close()                                                               
       if (s=="") then                                                            
           background_timers[cmd].timer:stop()                                    
           local lf = io.open(background_timers[cmd].file)                        
           funtocall(lf:read("*all"))                                             
           lf:close()
           io.popen("rm " .. background_timers[cmd].file)                                                            
       end                                                                        
   end)                                                                           
   background_timers[cmd].timer:start()                                           
end

