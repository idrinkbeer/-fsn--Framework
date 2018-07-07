local actions = {
  [1] = {
    name = "Shots Fired",
    tencode = '10-71',
    reward = 1000
  },
  [2] = {
    name = "Car Theft",
    tencode = '10-60',
    reward = 800
  },
  [3] = {
    name = "CDS Complaint",
    tencode = '10-31',
    reward = 350
  },
  [4] = {
    name = "OFFICER DOWN",
    tencode = '10-13',
    reward = 0
  },
  [5] = {
    name = "Officer Backup Requested",
    tencode = '10-77',
    reward = 0
  },
  [6] = {
    name = "EMERGENCY OFFICER BACKUP",
    tencode = '10-78',
    reward = 0
  },
[7] = {
    name = 'Bank Robbery',
    tencode = '10-90',
    reward = 500
  },
  [8] = {
    name = 'Speeding Vehicle',
    tencode = '10-98',
    reward = 500
  }
}
local dispatch_calls = {}
local disp_enable = false
local disp_id = 0
local last_disp = 0
local current_time = 0
local last_report_01 = 0

RegisterNetEvent('fsn_police:dispatch:toggle')
AddEventHandler('fsn_police:dispatch:toggle', function()
  if disp_enable then
    disp_enable = false
    TriggerEvent('fsn_notify:displayNotification', 'Dispatch: <b style="color:red">DISABLED', 'centerRight', 4000, 'info')
  else
    disp_enable = true
    TriggerEvent('fsn_notify:displayNotification', 'Dispatch: <b style="color:#42f474">ENABLED', 'centerRight', 4000, 'info')
  end
end)

function displayDispatch(x,y,z,id)
  if pdonduty then
    local var1, var2 = GetStreetNameAtCoord(x, y, z, Citizen.ResultAsInteger(), Citizen.ResultAsInteger())
    local sname = GetStreetNameFromHashKey(var1)
    SendNUIMessage({
      addDispatch = true,
      tencode = actions[id].tencode,
      name = actions[id].name,
      loc = sname,
      x = x,
      y = y,
      z = z
    })
    if disp_enable then
      disp_id = #dispatch_calls+1
      last_disp = current_time
      table.insert(dispatch_calls, disp_id, {
        type = actions[id].tencode,
        cx = x,
        cy = y
      })
	  if id == 7 then
		TriggerEvent('chatMessage', '', {255,255,255}, '^6^*:fsn_police:^0^r A BANK IS BEING ROBBED @ '..sname)
	  end
      SetNotificationTextEntry("STRING");
      AddTextComponentString('Call: ~r~'..actions[id].tencode..'~w~ ('..actions[id].name..')\nLocation: ~y~'..sname);
      SetNotificationMessage("CHAR_DEFAULT", "CHAR_DEFAULT", true, 1, "~g~DISPATCH:~s~", "");
      DrawNotification(false, true);
    end
  end
end

RegisterNetEvent('fsn_police:dispatchcall')
AddEventHandler('fsn_police:dispatchcall', function(tbl, id)
  displayDispatch(tbl.x,tbl.y,tbl.z,id)
end)

Citizen.CreateThread(function()
  while true do
    Citizen.Wait(1000)
    current_time = current_time + 1
  end
end)

Citizen.CreateThread(function()
   while true do
     Citizen.Wait(0)
     if IsPedShooting(GetPlayerPed(-1)) and not pdonduty then
       local pos = GetEntityCoords(GetPlayerPed(-1))
       local coords = {
         x = pos.x,
         y = pos.y,
         z = pos.z
       }
       TriggerServerEvent('fsn_police:dispatch', coords, 1)
     end


     ----- PD SIDE
     if disp_id ~= 0 then
       if last_disp + 10 > current_time then
         SetTextComponentFormat("STRING")
         AddTextComponentString("Press ~INPUT_MP_TEXT_CHAT_TEAM~ to ~g~accept~w~ the call\nPress ~INPUT_PUSH_TO_TALK~ to ~r~decline~w~ the call")
         DisplayHelpTextFromStringLabel(0, 0, 1, -1)
         if IsControlJustPressed(0, 246) then
           SetNewWaypoint(dispatch_calls[disp_id].cx, dispatch_calls[disp_id].cy)
           last_disp = 0
         end
         if IsControlJustPressed(0, 249) then
           last_disp = 0
         end
       end
     end
   end
end)
