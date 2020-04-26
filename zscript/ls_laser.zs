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

class m8f_ls_PuffBase : Actor abstract
{

  Default
  {
    Mass        0;
    Radius      1;
    Height      2;
    RenderStyle "Stencil";

    +NOBLOCKMAP;
    +NOGRAVITY;
    +BLOODLESSIMPACT;
    +PUFFONACTORS;
    +DONTSPLASH;
    +NOTRIGGER;
    +FORCEXYBILLBOARD;
    +NOTONAUTOMAP;
  }

  States
  {
    Spawn:
      TNT1 A 0;
      WDOB A 1 BRIGHT;
      Stop;
  }

} // class m8f_ls_PuffBase

class m8f_ls_InvisiblePuff : m8f_ls_PuffBase {States {Spawn: TNT1 A 0; Stop;}}
class m8f_ls_LaserPuff     : m8f_ls_PuffBase {States {Spawn: TNT1 A 0; WDO1 A -1 BRIGHT; Stop;}}

class ls_InvisibleSkyPuff : m8f_ls_InvisiblePuff { Default { +SKYEXPLODE; } }

class m8f_ls_BeamInvisiblePuff : m8f_ls_PuffBase
{

  Default
  {
    +SKYEXPLODE;
  }

  States
  {
    Spawn:
      TNT1 A 0;
      Stop;
  }

} // class m8f_ls_BeamInvisiblePuff
