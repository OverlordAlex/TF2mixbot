#include <sourcemod>
#include <sdktools>

int bt_num_players = 0;
int bt_players[24];
int bt_num_subs = 0;
int bt_subs[36];
int bt_max_players = 12;

public Plugin myinfo = 
{
    name = "Pickup Bot for ZA TF2",
    author = "Alex Wright",
    description = "A bot for managing pickups",
    version = "1.0",
    url = "N/A"
};

public void OnPluginStart()
{
    PrintToServer("*** Loaded pickupBot ***");
    RegConsoleCmd("add", Command_add);
    RegConsoleCmd("rem", Command_rem);
    RegConsoleCmd("show", Command_show);
    RegConsoleCmd("start", Command_show);
    RegConsoleCmd("set_players", Command_set_players);
    
    /*RegAdminCmd("pickup_remove_player", Command_remove, ADMFLAG_KICK);*/
    /*RegAdminCmd("pickup_start", Command_start, ADMFLAG_KICK);*/
}


public Action Command_add(client, args)
{
    for (int i = 0; i < bt_num_players; i++)
    {
        if (bt_players[i] == client)
        {
            LogAction(client, -1, "\"%L\" is already in the mix", client);
            ReplyToCommand(client, "ALREADY IN THE MIX...")
            return Plugin_Handled;
        }
    }
    for (int i = 0; i < bt_num_subs; i++)
    {
        if (bt_subs[i] == client)
        {
            LogAction(client, -1, "\"%L\" is already in the mix", client);
            ReplyToCommand(client, "ALREADY A SUB...")
            return Plugin_Handled;
        }
    }

    if (bt_num_players < bt_max_players)
    {
        bt_players[bt_num_players] = client;
        bt_num_players++;
        ReplyToCommand(client, "Added!")
        LogAction(client, -1, "\"%L\" was added to the mix", client);
    }
    else if (bt_num_subs < bt_max_players)
    {
        bt_subs[bt_num_subs] = client;
        bt_num_subs++;
        ReplyToCommand(client, "Subbed! (mix is full)")
        LogAction(client, -1, "\"%L\" was added as a sub", client);
    }
    else
    {
        ReplyToCommand(client, "MIX AND SUBS FULL!")
        LogAction(client, -1, "Mix full! \"%L\" was NOT added", client);
    }

    
    return Plugin_Handled;
}

public void deleteFromPlayers(int index)
{
    bt_players[index] = 0;
    for (int j = index; j < bt_num_players - 1; j++)
    {
        bt_players[j] = bt_players[j+1];
    }
    bt_num_players--;
}

public void deleteFromSubs(int index)
{
    bt_subs[index] = 0;
    for (int j = index; j < bt_num_subs - 1; j++)
    {
        bt_subs[j] = bt_subs[j+1];
    }
    bt_num_subs--;
}


public Action Command_rem(client, args)
{
    for (int i = 0; i < bt_num_players; i++)
    {
        if (bt_players[i] == client)
        {
            deleteFromPlayers(i);
            if (bt_num_subs > 0) 
            {
                Command_add(bt_subs[0], args);
                deleteFromSubs(0);
            }
            ReplyToCommand(client, "You have been removed")
            LogAction(client, -1, "\"%L\" was removed from the mix", client);
            return Plugin_Handled;
        }
    }
    for (int i = 0; i < bt_num_subs; i++)
    {
        if (bt_subs[i] == client)
        {
            deleteFromSubs(i);
            ReplyToCommand(client, "You have been removed")
            LogAction(client, -1, "\"%L\" was removed from the sub list", client);
            return Plugin_Handled;
        }
    }
    ReplyToCommand(client, "Couldnt find you in the list, did you even add?")
    return Plugin_Handled;
}

public Action:Command_show(client, args)
{
    PrintToChatAll("MIX: %d/%d players, %d ready to sub", bt_num_players, bt_max_players, bt_num_subs)
    PrintToChatAll("PLAYERS:");
    for (int i = 0; i < bt_num_players; i++)
    {
        decl String:name[64];
        GetClientName(bt_players[i], name, sizeof(name));
        LogAction(client, -1, "%s", name);
        PrintToChatAll("%s", name);
    }

    PrintToChatAll("SUBS:");
    for (int i = 0; i < bt_num_subs; i++)
    {
        decl String:name[64];
        GetClientName(bt_subs[i], name, sizeof(name));
        LogAction(client, -1, "%s", name);
        PrintToChatAll("%s", name);
    }
}

public Action:Command_remove(client, args)
{
    LogAction(client, -1, "TODO TODO TODO");
}

public Action:Command_start(client, args)
{
    Command_show(client, args);
    if (bt_num_players < bt_max_players)
    {
        ReplyToCommand(client, "Not enough players! Need %d!", bt_max_players)
        LogAction(client, -1, "Not enough players to start")
        return Plugin_Handled;
    } 
    bt_num_players = 0;
    bt_num_subs = 0;
    LogAction(client, -1, "Starting the mix!");
    return Plugin_Handled;
}

public Action:Command_set_players(client, args)
{
    decl String:nplayers[32];
    GetCmdArg(1, nplayers, sizeof(nplayers));
    bt_max_players = StringToInt(nplayers);
    if (bt_max_players > 24)
    {
        bt_max_players = 24;
        ReplyToCommand(client, "Cant have more than 24 max players!")
        LogAction(client, -1, "Cant have more than 24 max player!")
        return Plugin_Handled;
    }
    return Plugin_Handled;
}
