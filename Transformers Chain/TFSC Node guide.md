# 1. update and upgrade

    sudo apt update && sudo apt upgrade -y

# 2. install tmux

    sudo apt install tmux -y

# 3. Create folder for node

    cd $HOME && rm -rf $HOME/.transformers/ && mkdir -p $HOME/.transformers && cd $HOME/.transformers

# 4. node initialize

    wget https://fastcdn.uscloudmedia.com/transformers/formal/tfs_v0.33.1_92c26db_testnet.zip && unzip https://fastcdn.uscloudmedia.com/transformers/formal/tfs_v0.33.1_92c26db_testnet.zip && chmod +x tfs_v0.33.1_92c26db_testnet

# 5. Add ip address to config.json
    
    nano $HOME/.transformers/config.json
   
  #if u're using mobaxterm, u can simply open it through the UI. Next, make a backup of the key file, it is called <address>.private and is located in the .transformers/cert/ folder.

# 6. Create tmux session for running the node
    tmux new-session -s tfsc
# In the opened session, run the node with -m flag 
    $HOME/.transformers/ttfs_v0.8.0_76a6414_devnet -m


#Commands for tmux:
      ctrl+b and then d - close session 
      tmux attach - attach to a session. cheers! 
