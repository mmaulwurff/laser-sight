// Copyright 2018-2020 Alexander Kromm (m8f/mmaulwurff)
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see http://www.gnu.org/licenses/

class m8f_ls_EventHandler : EventHandler
{

  // overrides section /////////////////////////////////////////////////////////

  override void OnRegister()
  {
    _isInitialized = false;
  }

  override void WorldLoaded(WorldEvent event)
  {
    _isTitlemap = CheckTitlemap();
  }

  override void WorldTick()
  {
    if (_isTitlemap) { return; }

    if (!_isInitialized) { SetupPuff(players[consolePlayer]); }

    if (!_puff) { return; }

    _puff.bInvisible = true;

    if (_settings.hideOnSlot1() && IsSlot1(_player)) { return; }

    if (_settings.onlyWhenReady() && !IsWeaponReady(_player)) { return; }

    bool showLaserSight = CVar.GetCVar("m8f_wm_ShowLaserSight", _player).GetInt();
    if (!showLaserSight) { return; }

    if (_player.readyWeapon == null) { return; }

    CVar targetCVar       = CVar.GetCVar("m8f_ts_has_target", _player);
    CVar friendlyCVar     = CVar.GetCVar("m8f_ts_friendly_target", _player);
    bool hasTarget        = (targetCVar   != null && targetCVar.GetInt());
    bool isTargetFriendly = (friendlyCVar != null && friendlyCVar.GetInt());

    bool negative = (_settings.targetColorChange()   && hasTarget);
    bool friendly = (_settings.friendlyColorChange() && isTargetFriendly);

    ShowLaserSight(negative, friendly, _player);
  }

  // methods section ///////////////////////////////////////////////////////////

  private void SetupPuff(PlayerInfo player)
  {
    if (player == null) { return; }

    // clear existing laser points
    Array<Actor> deleteList;
    let iterator = ThinkerIterator.Create("m8f_ls_LaserPuff");
    Actor toDelete;
    while (toDelete = Actor(iterator.next(true)))
    {
      deleteList.push(toDelete);
    }
    int size = deleteList.size();
    for (int i = 0; i < size; ++i)
    {
      deleteList[i].Destroy();
    }

    _player        = players[consolePlayer];
    _settings      = m8f_ls_Settings.of();
    _puff          = Actor.Spawn("m8f_ls_LaserPuff");
    _isInitialized = true;

    _puff.bInvisible = true;
  }

  private void ShowLaserSight(bool negative, bool friendly, PlayerInfo player)
  {
    Actor a = player.mo;
    if (a == null) { return; }

    double pitch = a.AimTarget() ? a.BulletSlope(null, ALF_PORTALRESTRICT) : a.pitch;

    MaybeShowDot(pitch, a, negative, friendly);
    MaybeShowBeam(pitch, a, negative, friendly);
  }

  private void MaybeShowDot(double pitch, Actor a, bool negative, bool friendly)
  {
    Actor  tempPuff = a.LineAttack( a.angle
                                  , 4000.0
                                  , pitch
                                  , 0
                                  , "none"
                                  , "m8f_ls_InvisiblePuff"
                                  , lFlags
                                  );

    if (tempPuff == null) { return; }

    double distance = a.Distance3D(tempPuff);
    if (_settings.hideOnCloseDistance() && distance < minDistance) { return; }

    double scale   = _settings.scale() * distance / 250.0;
    double opacity = _settings.opacity();

    string shade;
    if (friendly)      { shade = _settings.friendlyColor(); }
    else if (negative) { shade = _settings.targetColor();   }
    else               { shade = _settings.noTargetColor(); }

    _puff.SetShade(shade);
    _puff.scale.x    = scale;
    _puff.scale.y    = scale;
    _puff.bInvisible = false;
    _puff.alpha      = opacity;
    _puff.SetOrigin(tempPuff.pos, true);
  }

  private void MaybeShowBeam(double pitch, Actor a, bool negative, bool friendly)
  {
    if (!_settings.beamEnabled()) { return; }

    Actor  tempPuff = a.LineAttack( a.angle
                                  , 4000.0
                                  , pitch
                                  , 0
                                  , "none"
                                  , "m8f_ls_BeamInvisiblePuff"
                                  , lFlags
                                  );

    if (tempPuff == null) { return; }

    double distance = a.Distance3D(tempPuff);

    string shade;
    if (friendly)      { shade = _settings.friendlyColor(); }
    else if (negative) { shade = _settings.targetColor();   }
    else               { shade = _settings.noTargetColor(); }

    showBeam(a, tempPuff.pos, distance, shade);
  }

  private void ShowBeam(Actor a, vector3 targetPos, double distance, string shade)
  {
    color   beamColor  = shade;
    double  size       = 2.0 * _settings.beamScale();

    double  viewHeight = a.player.viewz - a.pos.z - PlayerPawn(a).attackZOffset;
    targetPos.z -= viewHeight;

    vector3 relPos = targetPos - a.pos;
    int     nSteps = int(distance / _settings.beamStep());

    if (nSteps == 0) { return; }

    double  xStep     = relPos.x / nSteps;
    double  yStep     = relPos.y / nSteps;
    double  zStep     = relPos.z / nSteps;
    double  alpha     = _settings.opacity();
    int     drawSteps = nSteps - 2;

    for (int i = 2; i < drawSteps; ++i)
    {
      double xoff = xStep * i;
      double yoff = yStep * i;
      double zoff = zStep * i + viewHeight;

      a.A_SpawnParticle( beamColor, beamFlags, beamLifetime, size, beamAngle
                       , xoff, yoff, zoff
                       , beamVel, beamVel, beamVel, beamAcc, beamAcc, beamAcc
                       , alpha
                       );
    }
  }

  // static functions section //////////////////////////////////////////////////

  private play static bool IsSlot1(PlayerInfo player)
  {
    Weapon w = player.readyWeapon;
    if (w == null) { return false; }

    int located;
    int slot;
    [located, slot] = player.weapons.LocateWeapon(w.GetClassName());

    bool slot1 = (slot == 1);
    return slot1;
  }

  private static bool CheckTitlemap()
  {
    bool isTitlemap = (level.mapname == "TITLEMAP");
    return isTitlemap;
  }

  private static bool IsWeaponReady(PlayerInfo player)
  {
    if (!player) { return false; }

    bool isReady = (player.WeaponState & WF_WEAPONREADY)
      || (player.WeaponState & WF_WEAPONREADYALT);

    return isReady;
  }

  // constants section /////////////////////////////////////////////////////////

  const minDistance = 50.0;
  const lFlags      = LAF_NOIMPACTDECAL | LAF_NORANDOMPUFFZ;

  const beamLifetime = 1;
  const beamFlags    = SPF_FULLBRIGHT;
  const beamAngle    = 0.0;
  const beamVel      = 0.0;
  const beamAcc      = 0.0;

  // attributes section ////////////////////////////////////////////////////////

  private bool            _isTitlemap;
  private bool            _isInitialized;
  private m8f_ls_Settings _settings;
  private PlayerInfo      _player;
  private Actor           _puff;

} // class m8f_ls_EventHandler
