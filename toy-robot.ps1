#$ScriptDirectory = Split-Path -Path $MyInvocation.MyCommand.Definition -Parent
#. ("$ScriptDirectory\lib\Robot.ps1")
#. ("$ScriptDirectory\lib\Table.ps1")
#Import-Module .\lib\Table.psm1
#Import-Module .\lib\Robot.psm1

class Table {
    hidden [Int]$x = 0
    hidden [Int]$y = 0
    hidden [Int]$xx = 5
    hidden [Int]$yy = 5

    Table() {}

    Table([int]$xSize, [int]$ySize){
        $this.xx = $xSize
        $this.yy = $ySize
    }

    [bool] ContainsCoordinate ([int]$xCoordinate, [int]$yCoordinate) {
        return ($xCoordinate -ge $this.x -and $xCoordinate -le $this.xx -and $yCoordinate -ge $this.y -and $yCoordinate -le $this.yy) ? $true : $false
    }

}


class Robot {
    hidden [Table]$table
    hidden [Int]$x
    hidden [Int]$y
    hidden [Direction]$facing

    Robot () {}

    Robot ([Table]$table) { $this.table = $table }

    Robot ([int]$x, [int]$y, [Direction]$facing, [Table]$table) {
        $this.x = $x
        $this.y = $y
        $this.facing = $facing
        $this.table = $table
    }

    [Robot] Place ([int]$x, [int]$y, [Direction]$facing, [Table]$table) {
        return ($table -is [Table]) -and ($table.ContainsCoordinate($x, $y)) ? [Robot]::new($x, $y, $facing, $table) : $this
    }

    [Robot] Move () {
        return $this.Place(
                            $this.x + [Math]::Round([Math]::Sin([Math]::pi*([int]$this.facing/180))), 
                            $this.y + [Math]::Round([Math]::Cos([Math]::pi*([int]$this.facing/180))), 
                            $this.facing, 
                            $this.table
                        )
    }

    [Robot] Left () {      
        return $this.Place($this.x, $this.y, [MathUtil]::FMod($this.facing-90, 360), $this.table)
    }

    [Robot] Right () {
        return $this.Place($this.x, $this.y, [MathUtil]::FMod($this.facing+90, 360), $this.table)
    }

    [Robot] Report () {
        ($this.table -is [Table]) ? (Write-Host $this.x,$this.y,$this.facing) : [void] 
        return $this
    }

    # hide inherited methods
    hidden [bool] Equals ([System.Object]$obj) { return $true }
    hidden [int] GetHashCode() { return 0 }
    hidden [type] GetType() { return [Robot] }
    hidden [string] ToString() { return "robot" }

}

class MathUtil {
    static [int] FMod ([int]$x, [int]$y) {
        return ($x - $y * [Math]::Floor($x/$y))
    }
}

enum Direction {
    NORTH = 0
    EAST = 90
    SOUTH = 180
    WEST = 270
}

class RobotRunner {

    static Run () {
        $r = [Robot]::new()
        $t = [Table]::new()
        $in = ""
        do {
            $in = Read-Host
            $cmd,$arg,$_ = $in -split " "
            $arg = $arg -split ","
            if ($cmd.ToLower() -eq "place" `
                -and $arg.Length -eq 3 `
                -and [bool]($arg[0] -as [int]) `
                -and [bool]($arg[1] -as [int]) `
                -and $arg[2] -in [Direction].GetEnumNames()) {
                $r = $r.Place($arg[0] -as [int],$arg[1] -as [int],[Direction]::($arg[2]),$t)
            } else {
                $r = $in -in ($r | Get-Member -MemberTyp Method).Name ? $r.$in() : $r
            }
        } while ($in -ne "exit")
    }
}