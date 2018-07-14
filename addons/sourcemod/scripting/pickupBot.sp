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
    RegConsoleCmd("start", Command_start);
    RegConsoleCmd("set_players", Command_set_players);
    
    RegAdminCmd("rem_player", Command_remove, ADMFLAG_CUSTOM3);
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
}

public void print_names()
{
    PrintToChatAll("PLAYERS:");
    decl String:all_players[255];
    int nn = 0;
    for (int i = 0; i < bt_num_players; i++)
    {
        decl String:name[32];
        GetClientName(bt_players[i], name, sizeof(name));
        StrCat(String:all_players, 255, String:name);
        StrCat(all_players, 255, "::");
        nn++;
        if (nn == 7)
        {
            PrintToChatAll("%s", all_players);
            all_players = "";
            nn = 0;
        }
    }
    if (nn > 0)
    {
        PrintToChatAll("%s", all_players);
        all_players = "";
        nn = 0;
    }

    PrintToChatAll("SUBS:");
    for (int i = 0; i < bt_num_subs; i++)
    {
        decl String:name[32];
        GetClientName(bt_subs[i], name, sizeof(name));
        StrCat(all_players, 255, name);
        StrCat(all_players, 255, "::");
        nn++;
        if (nn == 7)
        {
            PrintToChatAll("%s", all_players);
            all_players = "";
            nn = 0;
        }
    }
    if (nn > 0)
    {
        PrintToChatAll("%s", all_players);
    }
}

public Action:Command_remove(client, args)
{
    decl String:player_id[32];
    GetCmdArg(1, player_id, sizeof(player_id));
    int tmp = 0;
    tmp = StringToInt(player_id);

    for (int i = 0; i < bt_num_players; i++)
    {
        if (bt_players[i] == tmp)
        {
            deleteFromPlayers(i);
            if (bt_num_subs > 0)
            {
                Command_add(bt_subs[0], args);
                deleteFromSubs(0);
            }
            ReplyToCommand(client, "Removed from mix!")
            return Plugin_Handled;
        }
    }
    for (int i = 0; i < bt_num_subs; i++)
    {
        if (bt_subs[i] == tmp)
        {
            deleteFromSubs(i);
            ReplyToCommand(client, "Removed from subs")
            return Plugin_Handled;
        }
    }
    return Plugin_Handled;
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
    print_names();
    bt_num_players = 0;
    bt_num_subs = 0;
    LogAction(client, -1, "Starting the mix!");
    return Plugin_Handled;
}

public Action:Command_set_players(client, args)
{
    decl String:nplayers[32];
    GetCmdArg(1, nplayers, sizeof(nplayers));
    int tmp = 0;
    tmp = StringToInt(nplayers);
    if (tmp > 24)
    {
        bt_max_players = 24;
        ReplyToCommand(client, "Cant have more than 24 max players!")
        LogAction(client, -1, "Cant have more than 24 max player!")
        return Plugin_Handled;
    }
    if (tmp < 2)
    {
        bt_max_players = 2;
        ReplyToCommand(client, "Cant have less than 2 players!")
        LogAction(client, -1, "Cant have less than 2 players!")
        return Plugin_Handled;
    }
    bt_max_players = tmp;
    return Plugin_Handled;
}
