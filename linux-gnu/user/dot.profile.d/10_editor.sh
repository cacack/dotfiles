# Set the default editor to vim.                                                                        
if [ -x `which vim` ]; then                                                                             
  export EDITOR=vim                                                                                     
elif [ -x `which vi` ]; then                                                                            
  export EDITOR=vi                                                                                      
fi                                                                                                      
export VISUAL=$EDITOR
