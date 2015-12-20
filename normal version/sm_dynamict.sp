#include <sourcemod> 
#include <sdktools> 
#include <sdkhooks> 
//#include <zombiereloaded>

#define PLUGIN_VERSION "1.2" 

new Handle:esa_cvar, Handle:cvar_distance, Handle:cvar_alpha;

new Float:g_distance, g_alpha;

public Plugin:myinfo =  
{ 
    name = "SM Dynamic Transparencies", 
    author = "Franc1sco franug", 
    description = "", 
    version = PLUGIN_VERSION, 
    url = "http://steamcommunity.com/id/franug" 
} 

public OnPluginStart() 
{ 
	CreateConVar("sm_dynamictransparencies", PLUGIN_VERSION, "", FCVAR_NOTIFY|FCVAR_PLUGIN|FCVAR_DONTRECORD);
	CreateTimer(0.5, Pasar, _, TIMER_REPEAT);
	
	cvar_alpha = CreateConVar("sm_dt_alpha", "80", "Transparency value to the players");
	cvar_distance = CreateConVar("sm_dt_distance", "200.0", "Distance for turn on the transparency in the players");
	
	HookConVarChange(cvar_alpha, ConVarChangedcfg);
	HookConVarChange(cvar_distance, ConVarChangedcfg);
	
	g_alpha = GetConVarInt(cvar_alpha);
	g_distance = GetConVarFloat(cvar_distance);
	
	esa_cvar = FindConVar("sv_disable_immunity_alpha");
	if(esa_cvar == INVALID_HANDLE)
		return;
		
	SetConVarInt(esa_cvar, 1);
	
	HookConVarChange(esa_cvar, ConVarChanged);
}

public ConVarChanged(Handle:cvar, const String:oldVal[], const String:newVal[])
{
	SetConVarInt(esa_cvar, 1);
}

public ConVarChangedcfg(Handle:cvar, const String:oldVal[], const String:newVal[])
{
	g_alpha = GetConVarInt(cvar_alpha);
	g_distance = GetConVarFloat(cvar_distance);
}

public Action:Pasar(Handle:timer)
{
	for(new i = 1; i <= MaxClients; i++)
		//if(IsClientInGame(i) && IsPlayerAlive(i) && ZR_IsClientHuman(i))
		if(IsClientInGame(i) && IsPlayerAlive(i))
			CheckClientOrg(i);

}

CheckClientOrg(Client) 
{
	
	decl Float:MedicOrigin[3],Float:TargetOrigin[3], Float:Distance;
	GetClientAbsOrigin(Client, MedicOrigin);
	new bool:cerca = false;
	for (new X = 1; X <= MaxClients; X++)
	{
		//if(IsClientInGame(X) && IsPlayerAlive(X) && X != Client && ZR_IsClientHuman(X))
		if(IsClientInGame(X) && IsPlayerAlive(X) && X != Client && GetClientTeam(X) == GetClientTeam(Client))
		{
			GetClientAbsOrigin(X, TargetOrigin);
			Distance = GetVectorDistance(TargetOrigin,MedicOrigin);
			if(Distance <= g_distance)
			{
				cerca = true;
				SetEntityRenderColor(Client, 255, 255, 255, g_alpha);
				//PrintToChat(Client, "puesto");
				break;
			}
		}
		
	}
	if(!cerca)
	{
		SetEntityRenderColor(Client, 255, 255, 255, 255);
		//PrintToChat(Client, "quitado");
	}
}