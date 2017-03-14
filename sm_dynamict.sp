/*  SM Dynamic Transparencies
 *
 *  Copyright (C) 2017 Francisco 'Franc1sco' García
 * 
 * This program is free software: you can redistribute it and/or modify it
 * under the terms of the GNU General Public License as published by the Free
 * Software Foundation, either version 3 of the License, or (at your option) 
 * any later version.
 *
 * This program is distributed in the hope that it will be useful, but WITHOUT 
 * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS 
 * FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License along with 
 * this program. If not, see http://www.gnu.org/licenses/.
 */

#include <sourcemod> 
#include <sdktools> 
#include <sdkhooks> 
#undef REQUIRE_PLUGIN
#include <zombiereloaded>

#define PLUGIN_VERSION "1.3"

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

public APLRes:AskPluginLoad2(Handle:myself, bool:late, String:error[], err_max)
{
	MarkNativeAsOptional("ZR_IsClientHuman");
	return APLRes_Success;
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
		if(IsClientInGame(i) && IsPlayerAlive(i) && (GetFeatureStatus(FeatureType_Native, "ZR_IsClientHuman") != FeatureStatus_Available || ZR_IsClientHuman(i)))
			CheckClientOrg(i);

}

CheckClientOrg(Client) 
{
	
	decl Float:MedicOrigin[3],Float:TargetOrigin[3], Float:Distance;
	GetClientAbsOrigin(Client, MedicOrigin);
	new bool:cerca = false;
	for (new X = 1; X <= MaxClients; X++)
	{
		if(IsClientInGame(X) && IsPlayerAlive(X) && X != Client)
		{
			if (GetFeatureStatus(FeatureType_Native, "ZR_IsClientHuman") == FeatureStatus_Available)
			{
				if (!ZR_IsClientHuman(X))continue;
			}
			else 
			{
				if (GetClientTeam(X) != GetClientTeam(Client)) continue;
			}
			
			
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