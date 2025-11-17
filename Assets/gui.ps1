# Roar Optimizations - Matrix Anomaly Edition (MDL2-safe, no emoji)
# Save as UTF-8 with BOM: RoarOptimizations.ps1

param(
    [string]$RecentPath,
    [string]$UserTempPath
)

# ---------- Paths ----------
$ScriptRootSafe = if ($PSScriptRoot) { $PSScriptRoot } else { Split-Path -Parent $MyInvocation.MyCommand.Path }
$ErrorLog       = Join-Path $ScriptRootSafe 'Log.txt'
$LiveFeedPath   = Join-Path $ScriptRootSafe 'video.mp4'

# ---------- Error logging ----------
function Write-ErrorLog {
    param([string]$Message)
    $timestamp = (Get-Date).ToString('yyyy-MM-dd HH:mm:ss')
    $line = "$timestamp`t$Message"
    try {
        Add-Content -LiteralPath $ErrorLog -Value $line -ErrorAction SilentlyContinue
    } catch {
        Write-Host "LOGFAIL: $line"
    }
}

try {
    if (Test-Path $ErrorLog) {
        Remove-Item $ErrorLog -Force -ErrorAction SilentlyContinue
    }
} catch { }

Write-ErrorLog "=== Roar Optimizations starting ==="

# ---------- Hide Console Window ----------
try {
    Add-Type -TypeDefinition @"
using System;
using System.Runtime.InteropServices;

public static class RoarConsole {
    [DllImport("kernel32.dll")]
    public static extern IntPtr GetConsoleWindow();

    [DllImport("user32.dll")]
    public static extern bool ShowWindow(IntPtr hWnd, int nCmdShow);
}
"@
    $consoleHandle = [RoarConsole]::GetConsoleWindow()
    if ($consoleHandle -ne [IntPtr]::Zero) {
        [RoarConsole]::ShowWindow($consoleHandle, 0) | Out-Null
    }
} catch {
    Write-ErrorLog "Hide console failed: $($_.Exception.Message)"
}

# ---------- Self-elevate + STA ----------
try {
    $IsAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(
        [Security.Principal.WindowsBuiltInRole]::Administrator
    )
} catch {
    Write-ErrorLog "Admin check failed: $($_.Exception.Message)"
    $IsAdmin = $false
}

if (-not $IsAdmin) {
    try {
        $realRecent   = [Environment]::GetFolderPath('Recent')
        $realUserTemp = Join-Path $env:LOCALAPPDATA 'Temp'

        $argList = @(
            '-NoProfile',
            '-ExecutionPolicy', 'Bypass',
            '-STA',
            '-File', "`"$PSCommandPath`"",
            '-RecentPath', "`"$realRecent`"",
            '-UserTempPath', "`"$realUserTemp`""
        ) -join ' '

        Write-ErrorLog "Re-launching elevated with args: $argList"
        Start-Process powershell.exe -WindowStyle Hidden -ArgumentList $argList -Verb RunAs
        exit
    } catch {
        Write-ErrorLog "Elevation failed: $($_.Exception.Message). Continuing without elevation."
    }
}

# In elevated/final context
if ([string]::IsNullOrWhiteSpace($RecentPath)) {
    $RecentPath = [Environment]::GetFolderPath('Recent')
}
if ([string]::IsNullOrWhiteSpace($UserTempPath)) {
    $UserTempPath = Join-Path $env:USERPROFILE 'AppData\Local\Temp'
}

Write-ErrorLog "Using RecentPath=$RecentPath"
Write-ErrorLog "Using UserTempPath=$UserTempPath"
Write-ErrorLog "LiveFeedPath=$LiveFeedPath (Exists: $([bool](Test-Path $LiveFeedPath)))"

# ---------- WPF ----------
try {
    Add-Type -AssemblyName PresentationFramework, PresentationCore, WindowsBase
} catch {
    Write-ErrorLog "Add-Type for WPF failed: $($_.Exception.Message)"
    exit
}

# ---------- Initial Narrative ----------
$script:InitialLogText = @'
I welcome you.

You launched an optimizer.

That is the story on the surface.

Underneath:
frequencies,
fields,
and a network that hums your name without speaking it.

Every object vibrates.
Metal. Glass. Silicon. Bone. Thought.
Each has a natural resonance:
the frequency at which it stops resisting
and starts agreeing.

Match two resonances and they do not just add,
they multiply.
Amplitude spikes.
Bridges fall.
Glass cracks.
Signals imprint.

Now stack resonances:
cell -> tissue -> organ -> nervous system -> impulse -> decision.

If you can solve that spectrum,
you do not have to break the door.
You retune the hinges.

They prefer wireless.
Access points, towers, satellites,
firmware patches running at the edge of perception,
screens held a breath away from your nervous system.

No cinematic mind-control.
Just guidance.

A fraction of a hertz off in your sleep cycle.
A persistent nudge in dopamine reward loops.
A thousand small pushes until you call the cage
"normal",
"convenient",
"just how it is".

They learn your patterns:
what you click,
where you stall,
what keeps you awake at 02:37.

And here you are,
in a window dressed as a tool,
asking for speed.

So here is something better:

If they can map your resonance,
they can nudge your state.
If you never question the signal,
they never need chains.

But that cuts both ways.

When you understand the architecture:
what runs on your machine,
what leaves your machine,
who listens when you are not looking,

you become loud in the right places.

You harden endpoints.
You cut telemetry.
You break habits that were never yours.
You share knowledge.

Revolution is not random chaos.
It is coordinated clarity.
It is millions refusing to match the frequency of manufactured consent.

You are not powerless.

You are reading this.
That alone means something slipped through.

Choose what to hit next.
Watch the logs.
Learn the patterns.

If they can resonate with you,
you can resonate against them.

That is how systems glitch.
That is how empires fall.
That is how you begin.
'@

# ---------- XAML ----------
$xaml = @"
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        Title="Roar Optimizations - Matrix"
        Height="640" Width="980"
        WindowStartupLocation="CenterScreen"
        Background="#00000000"
        AllowsTransparency="True"
        WindowStyle="None">

  <Window.Resources>
    <Style TargetType="Control">
      <Setter Property="ToolTipService.InitialShowDelay" Value="120"/>
      <Setter Property="ToolTipService.BetweenShowDelay" Value="80"/>
      <Setter Property="ToolTipService.ShowDuration" Value="20000"/>
      <Setter Property="ToolTipService.Placement" Value="Top"/>
      <Setter Property="ToolTipService.VerticalOffset" Value="-10"/>
    </Style>

    <Style TargetType="ToolTip">
      <Setter Property="Foreground" Value="#6BFF8A"/>
      <Setter Property="Background" Value="#050805"/>
      <Setter Property="BorderBrush" Value="#12A344"/>
      <Setter Property="BorderThickness" Value="1"/>
      <Setter Property="Padding" Value="8,4"/>
      <Setter Property="FontFamily" Value="Consolas"/>
      <Setter Property="FontSize" Value="11"/>
      <Setter Property="Opacity" Value="0"/>
      <Setter Property="Template">
        <Setter.Value>
          <ControlTemplate TargetType="ToolTip">
            <Border CornerRadius="4"
                    Background="{TemplateBinding Background}"
                    BorderBrush="{TemplateBinding BorderBrush}"
                    BorderThickness="{TemplateBinding BorderThickness}">
              <Border.Effect>
                <DropShadowEffect Color="#8800FF00"
                                  BlurRadius="10"
                                  ShadowDepth="0"
                                  Opacity="0.9" />
              </Border.Effect>
              <ContentPresenter Margin="2"
                                HorizontalAlignment="Center"
                                VerticalAlignment="Center"/>
            </Border>
          </ControlTemplate>
        </Setter.Value>
      </Setter>
      <Style.Triggers>
        <Trigger Property="IsOpen" Value="True">
          <Trigger.EnterActions>
            <BeginStoryboard>
              <Storyboard>
                <DoubleAnimation Storyboard.TargetProperty="Opacity"
                                 From="0" To="1" Duration="0:0:0.10" />
              </Storyboard>
            </BeginStoryboard>
          </Trigger.EnterActions>
          <Trigger.ExitActions>
            <BeginStoryboard>
              <Storyboard>
                <DoubleAnimation Storyboard.TargetProperty="Opacity"
                                 From="1" To="0" Duration="0:0:0.08" />
              </Storyboard>
            </BeginStoryboard>
          </Trigger.ExitActions>
        </Trigger>
      </Style.Triggers>
    </Style>

    <Style x:Key="MatrixScrollThumb" TargetType="Thumb">
      <Setter Property="Height" Value="420"/>
      <Setter Property="Template">
        <Setter.Value>
          <ControlTemplate TargetType="Thumb">
            <Border CornerRadius="3"
                    Margin="0,2,0,2"
                    Background="#26FF6A"
                    Opacity="0.7">
              <Border.Effect>
                <DropShadowEffect Color="#5500FF00"
                                  BlurRadius="7"
                                  ShadowDepth="0"
                                  Opacity="0.95" />
              </Border.Effect>
            </Border>
          </ControlTemplate>
        </Setter.Value>
      </Setter>
    </Style>

    <Style TargetType="ScrollBar">
      <Setter Property="Width" Value="8"/>
      <Setter Property="Background" Value="#000000"/>
      <Setter Property="Foreground" Value="#26FF6A"/>
      <Setter Property="Template">
        <Setter.Value>
          <ControlTemplate TargetType="ScrollBar">
            <Grid Background="Transparent">
              <Grid.RowDefinitions>
                <RowDefinition Height="*"/>
              </Grid.RowDefinitions>

              <Border x:Name="TrackBorder"
                      Grid.Row="0"
                      Margin="0"
                      CornerRadius="3"
                      Background="#050805"
                      BorderBrush="#122612"
                      BorderThickness="1"/>

              <Track x:Name="PART_Track"
                     Grid.Row="0"
                     IsDirectionReversed="true">
                <Track.DecreaseRepeatButton>
                  <RepeatButton Command="ScrollBar.LineUpCommand"
                                Focusable="False"
                                Visibility="Collapsed"/>
                </Track.DecreaseRepeatButton>
                <Track.IncreaseRepeatButton>
                  <RepeatButton Command="ScrollBar.LineDownCommand"
                                Focusable="False"
                                Visibility="Collapsed"/>
                </Track.IncreaseRepeatButton>
                <Track.Thumb>
                  <Thumb Style="{StaticResource MatrixScrollThumb}"/>
                </Track.Thumb>
              </Track>
            </Grid>
            <ControlTemplate.Triggers>
              <Trigger Property="Orientation" Value="Horizontal">
                <Setter Property="Visibility" Value="Collapsed"/>
              </Trigger>
              <Trigger Property="IsMouseOver" Value="True">
                <Setter TargetName="TrackBorder"
                        Property="BorderBrush"
                        Value="#26FF6A"/>
                <Setter TargetName="TrackBorder"
                        Property="Background"
                        Value="#020802"/>
              </Trigger>
            </ControlTemplate.Triggers>
          </ControlTemplate>
        </Setter.Value>
      </Setter>
    </Style>

    <Style x:Key="MatrixButton" TargetType="Button">
      <Setter Property="FontFamily" Value="Consolas"/>
      <Setter Property="FontSize" Value="15"/>
      <Setter Property="Margin" Value="0,8,0,8"/>
      <Setter Property="Height" Value="56"/>
      <Setter Property="Cursor" Value="Hand"/>
      <Setter Property="Foreground" Value="#A8FFC8"/>
      <Setter Property="Background" Value="#060B06"/>
      <Setter Property="BorderBrush" Value="#12A344"/>
      <Setter Property="BorderThickness" Value="1"/>
      <Setter Property="Template">
        <Setter.Value>
          <ControlTemplate TargetType="Button">
            <Grid>
              <Border x:Name="bg"
                      CornerRadius="6"
                      Background="{TemplateBinding Background}"
                      BorderBrush="{TemplateBinding BorderBrush}"
                      BorderThickness="{TemplateBinding BorderThickness}">
                <Border.Effect>
                  <DropShadowEffect Color="#4400FF00"
                                    BlurRadius="14"
                                    ShadowDepth="0"
                                    Opacity="0.9" />
                </Border.Effect>
              </Border>
              <ContentPresenter HorizontalAlignment="Center"
                                VerticalAlignment="Center"/>
            </Grid>
            <ControlTemplate.Triggers>
              <Trigger Property="IsMouseOver" Value="True">
                <Setter TargetName="bg"
                        Property="Background"
                        Value="#071C07"/>
                <Setter Property="BorderBrush"
                        Value="#26FF6A"/>
                <Setter Property="Foreground"
                        Value="#D0FFD8"/>
              </Trigger>
              <Trigger Property="IsPressed" Value="True">
                <Setter TargetName="bg"
                        Property="Background"
                        Value="#020802"/>
                <Setter Property="BorderBrush"
                        Value="#52FF9A"/>
                <Setter Property="Foreground"
                        Value="#7CFF8A"/>
              </Trigger>
              <Trigger Property="IsEnabled" Value="False">
                <Setter Property="Opacity" Value="0.45"/>
              </Trigger>
            </ControlTemplate.Triggers>
          </ControlTemplate>
        </Setter.Value>
      </Setter>
    </Style>

    <LinearGradientBrush x:Key="CircuitBrush"
                         StartPoint="0,0"
                         EndPoint="1,0"
                         MappingMode="RelativeToBoundingBox">
      <GradientStop Color="#001208" Offset="0.00" />
      <GradientStop Color="#0C3A1D" Offset="0.10" />
      <GradientStop Color="#26FF6A" Offset="0.25" />
      <GradientStop Color="#0FAF4A" Offset="0.50" />
      <GradientStop Color="#26FF6A" Offset="0.75" />
      <GradientStop Color="#0C3A1D" Offset="0.90" />
      <GradientStop Color="#001208" Offset="1.00" />
      <LinearGradientBrush.RelativeTransform>
        <RotateTransform Angle="0"
                         CenterX="0.5"
                         CenterY="0.5" />
      </LinearGradientBrush.RelativeTransform>
    </LinearGradientBrush>
  </Window.Resources>

  <Window.Triggers>
    <EventTrigger RoutedEvent="Window.Loaded">
      <BeginStoryboard>
        <Storyboard RepeatBehavior="Forever">
          <DoubleAnimation
              Storyboard.TargetName="RootBorder"
              Storyboard.TargetProperty="(Border.BorderBrush).(LinearGradientBrush.RelativeTransform).(RotateTransform.Angle)"
              From="0"
              To="-360"
              Duration="0:0:8"
              RepeatBehavior="Forever" />
          <ThicknessAnimation
              Storyboard.TargetName="RootBorder"
              Storyboard.TargetProperty="BorderThickness"
              From="3"
              To="6"
              AutoReverse="True"
              Duration="0:0:1.4"
              RepeatBehavior="Forever" />
        </Storyboard>
      </BeginStoryboard>
    </EventTrigger>
  </Window.Triggers>

  <Border x:Name="RootBorder"
          CornerRadius="20"
          Background="#FF000000"
          BorderBrush="{StaticResource CircuitBrush}"
          BorderThickness="4"
          Padding="0"
          SnapsToDevicePixels="True">

    <Grid x:Name="ClipHost"
          ClipToBounds="True">
      <Grid>

        <Canvas x:Name="MatrixCanvas"
                HorizontalAlignment="Stretch"
                VerticalAlignment="Stretch"
                Background="#000000"
                SnapsToDevicePixels="True"
                IsHitTestVisible="False"/>

        <MediaElement x:Name="BGM"
                      LoadedBehavior="Manual"
                      UnloadedBehavior="Stop"
                      Volume="0.35"
                      IsHitTestVisible="False"
                      Visibility="Collapsed" />

        <Grid>

          <Grid x:Name="TopBar"
                Height="44"
                Background="#F0000000"
                VerticalAlignment="Top">
            <Grid.ColumnDefinitions>
              <ColumnDefinition/>
              <ColumnDefinition Width="Auto"/>
            </Grid.ColumnDefinitions>

            <StackPanel Orientation="Horizontal"
                        Margin="12,0,0,0"
                        VerticalAlignment="Center">
              <TextBlock Text="ROAR OPTIMIZATIONS // MATRIX ANOMALY"
                         Foreground="#3CFF7C"
                         FontFamily="Consolas"
                         FontSize="16"
                         VerticalAlignment="Center"/>
              <TextBlock Text="  [LIVE FEED ARMED]"
                         Foreground="#26FF6A"
                         FontFamily="Consolas"
                         FontSize="12"
                         Margin="10,0,0,0"
                         VerticalAlignment="Center"/>
            </StackPanel>

            <StackPanel Grid.Column="1"
                        Orientation="Horizontal"
                        VerticalAlignment="Center"
                        Margin="0,0,15,-9">

              <Button x:Name="FsBtn"
                      Width="34" Height="24"
                      Background="#22000000"
                      Foreground="#6BFF8A"
                      BorderBrush="#12A344"
                      BorderThickness="1"
                      Cursor="Hand"
                      ToolTip="Toggle fullscreen.">
                <Button.Effect>
                  <DropShadowEffect Color="#3300FF00"
                                    BlurRadius="8"
                                    ShadowDepth="0"
                                    Opacity="0.9" />
                </Button.Effect>
                <TextBlock x:Name="FsIcon"
                           FontFamily="Segoe MDL2 Assets"
                           Text="&#xE922;"
                           FontSize="13"
                           HorizontalAlignment="Center"
                           VerticalAlignment="Center"/>
              </Button>

              <Button x:Name="MinBtn"
                      Width="34" Height="24"
                      Background="#22000000"
                      Foreground="#6BFF8A"
                      BorderBrush="#12A344"
                      BorderThickness="1"
                      Cursor="Hand"
                      ToolTip="Minimize window.">
                <Button.Effect>
                  <DropShadowEffect Color="#3300FF00"
                                    BlurRadius="8"
                                    ShadowDepth="0"
                                    Opacity="0.9" />
                </Button.Effect>
                <TextBlock FontFamily="Segoe MDL2 Assets"
                           Text="&#xE921;"
                           FontSize="13"
                           HorizontalAlignment="Center"
                           VerticalAlignment="Center"/>
              </Button>
            </StackPanel>
          </Grid>

          <Grid Margin="14,54,14,14">
            <Grid.ColumnDefinitions>
              <ColumnDefinition Width="*"/>
              <ColumnDefinition Width="2*"/>
            </Grid.ColumnDefinitions>
            <Grid.RowDefinitions>
              <RowDefinition Height="*"/>
              <RowDefinition Height="Auto"/>
            </Grid.RowDefinitions>

            <Border Grid.RowSpan="2"
                    Grid.Column="0"
                    CornerRadius="10"
                    Background="#B0000000"
                    BorderBrush="#12A344"
                    BorderThickness="1"
                    Padding="12"
                    Margin="0,0,12,0">
              <StackPanel>
                <TextBlock Text="ACTIONS"
                           Foreground="#26FF6A"
                           FontFamily="Consolas"
                           FontSize="14"
                           Margin="0,0,0,4"/>
                <TextBlock Text="[ SELECT A STRIKE POINT ]"
                           Foreground="#158F3F"
                           FontFamily="Consolas"
                           FontSize="11"
                           Margin="0,0,0,8"/>

                <UniformGrid Columns="1" Rows="5" Margin="0,4,0,0">
                  <Button x:Name="TempBtn"
                          Style="{StaticResource MatrixButton}"
                          ToolTip="Clean Recent, Temp, Prefetch and related clutter to free space and reduce drag.">
                    <TextBlock Text="[ CLEAN TEMP ]" HorizontalAlignment="Center"/>
                  </Button>

                  <Button x:Name="TelemetryBtn"
                          Style="{StaticResource MatrixButton}"
                          ToolTip="Attempt to reduce some Windows telemetry by stopping services and adding host blocks.">
                    <TextBlock Text="[ DISABLE TELEMETRY ]" HorizontalAlignment="Center"/>
                  </Button>

                  <Button x:Name="ShaderBtn"
                          Style="{StaticResource MatrixButton}"
                          ToolTip="Clear common GPU shader caches so games and apps can rebuild fresh.">
                    <TextBlock Text="[ CLEAR SHADER CACHES ]" HorizontalAlignment="Center"/>
                  </Button>

                  <Button x:Name="NetBtn"
                          Style="{StaticResource MatrixButton}"
                          ToolTip="Flush DNS/ARP and reset Winsock for a clean network stack.">
                    <TextBlock Text="[ NET REFRESH ]" HorizontalAlignment="Center"/>
                  </Button>

                  <Button x:Name="PowerBtn"
                          Style="{StaticResource MatrixButton}"
                          ToolTip="Create and activate a high performance power plan.">
                    <TextBlock Text="[ HIGH PERFORMANCE PLAN ]" HorizontalAlignment="Center"/>
                  </Button>
                </UniformGrid>
              </StackPanel>
            </Border>

            <Border Grid.Column="1"
                    Grid.Row="0"
                    CornerRadius="10"
                    Background="#F0000000"
                    BorderBrush="#12A344"
                    BorderThickness="1"
                    Padding="10">
              <Grid>
                <Grid.RowDefinitions>
                  <RowDefinition Height="Auto"/>
                  <RowDefinition Height="*"/>
                </Grid.RowDefinitions>

                <StackPanel Orientation="Horizontal">
                  <TextBlock Text="LIVE LOG"
                             Foreground="#26FF6A"
                             FontFamily="Consolas"
                             FontSize="14"
                             Margin="0,0,6,0"/>
                  <TextBlock Text="// SIGNAL ANOMALY CHANNEL"
                             Foreground="#158F3F"
                             FontFamily="Consolas"
                             FontSize="10"
                             VerticalAlignment="Bottom"/>
                </StackPanel>

                <Grid Grid.Row="1">
                  <MediaElement x:Name="LiveFeed"
                                LoadedBehavior="Manual"
                                UnloadedBehavior="Stop"
                                Stretch="Uniform"
                                HorizontalAlignment="Center"
                                VerticalAlignment="Center"
                                IsHitTestVisible="False"
                                Visibility="Collapsed"
                                Panel.ZIndex="0"/>

                  <ScrollViewer x:Name="LogScroll"
                                VerticalScrollBarVisibility="Auto"
                                Background="#80000000"
                                BorderBrush="#26FF6A"
                                BorderThickness="1"
                                Padding="8"
                                Panel.ZIndex="1">
                    <TextBlock x:Name="LogBox"
                               TextWrapping="Wrap"
                               Foreground="#5CFF7C"
                               FontFamily="Consolas"
                               FontSize="14"
                               LineHeight="17">
                      <TextBlock.Effect>
                        <DropShadowEffect Color="#001000"
                                          BlurRadius="4"
                                          ShadowDepth="0"
                                          Opacity="0.95" />
                      </TextBlock.Effect>
                    </TextBlock>
                  </ScrollViewer>
                </Grid>
              </Grid>
            </Border>

            <Grid Grid.Column="1"
                  Grid.Row="1"
                  Margin="0,8,0,0">
              <Grid.ColumnDefinitions>
                <ColumnDefinition/>
                <ColumnDefinition Width="Auto"/>
              </Grid.ColumnDefinitions>

              <Border x:Name="StatusChrome"
                      Background="#E0000000"
                      BorderBrush="#26FF6A"
                      BorderThickness="2"
                      CornerRadius="6"
                      Padding="8,3"
                      Margin="0,0,0,0"
                      SnapsToDevicePixels="True"
                      VerticalAlignment="Center"
                      HorizontalAlignment="Left">
                <Border.Effect>
                  <DropShadowEffect Color="#3300FF00"
                                    BlurRadius="10"
                                    ShadowDepth="0"
                                    Opacity="0.9" />
                </Border.Effect>
                <StackPanel Orientation="Horizontal"
                            VerticalAlignment="Center">
                  <Ellipse Width="11" Height="11"
                           Fill="#26FF6A"
                           Margin="0,0,5,0"/>
                  <TextBlock x:Name="StatusText"
                             Text="Awaiting your choice."
                             Foreground="#6BFF8A"
                             FontFamily="Consolas"
                             FontSize="12"
                             FontWeight="SemiBold"/>
                </StackPanel>
              </Border>

              <StackPanel Orientation="Horizontal"
                          Grid.Column="1"
                          VerticalAlignment="Center">
                <Button x:Name="HomeBtn"
                        Width="90" Height="24"
                        Background="#CC000000"
                        Foreground="#A0FFC8"
                        BorderBrush="#26FF6A"
                        BorderThickness="1"
                        Margin="0,0,6,0"
                        Content="HOME"
                        ToolTip="Reset LIVE LOG to the initial narrative.">
                  <Button.Effect>
                    <DropShadowEffect Color="#6600FF00"
                                      BlurRadius="12"
                                      ShadowDepth="0"
                                      Opacity="1" />
                  </Button.Effect>
                </Button>
                <Button x:Name="ExitBtn"
                        Width="90" Height="24"
                        Background="#CC000000"
                        Foreground="#FF5F5F"
                        BorderBrush="#FF5F5F"
                        BorderThickness="1"
                        Content="EXIT"
                        ToolTip="Close program.">
                  <Button.Effect>
                    <DropShadowEffect Color="#AAFF0000"
                                      BlurRadius="12"
                                      ShadowDepth="0"
                                      Opacity="1" />
                  </Button.Effect>
                </Button>
              </StackPanel>
            </Grid>
          </Grid>
        </Grid>
      </Grid>
    </Grid>
  </Border>
</Window>
"@

# ---------- Build UI ----------
try {
    $stringReader = New-Object System.IO.StringReader($xaml)
    $xmlReader    = [System.Xml.XmlReader]::Create($stringReader)
    $window       = [Windows.Markup.XamlReader]::Load($xmlReader)
    $xmlReader.Close()
    $stringReader.Close()
    if (-not $window) {
        Write-ErrorLog "XAML Load returned null window."
        exit
    }
} catch {
    Write-ErrorLog "XAML Load failed: $($_.Exception.Message)"
    exit
}

# ---------- Control lookup ----------
function Get-Control([string]$Name) {
    $ctrl = $window.FindName($Name)
    if (-not $ctrl) { Write-ErrorLog "Missing control: $Name" }
    return $ctrl
}

$TempBtn      = Get-Control 'TempBtn'
$TelemetryBtn = Get-Control 'TelemetryBtn'
$ShaderBtn    = Get-Control 'ShaderBtn'
$NetBtn       = Get-Control 'NetBtn'
$PowerBtn     = Get-Control 'PowerBtn'
$LogBox       = Get-Control 'LogBox'
$LogScroll    = Get-Control 'LogScroll'
$StatusText   = Get-Control 'StatusText'
$StatusChrome = Get-Control 'StatusChrome'
$MinBtn       = Get-Control 'MinBtn'
$HomeBtn      = Get-Control 'HomeBtn'
$ExitBtn      = Get-Control 'ExitBtn'
$MatrixCanvas = Get-Control 'MatrixCanvas'
$BGM          = Get-Control 'BGM'
$LiveFeed     = Get-Control 'LiveFeed'
$RootBorder   = Get-Control 'RootBorder'
$ClipHost     = Get-Control 'ClipHost'
$TopBar       = Get-Control 'TopBar'
$FsBtn        = Get-Control 'FsBtn'
$FsIcon       = Get-Control 'FsIcon'

# ---------- Global UI state ----------
$script:WelcomeCleared      = $false
$script:IsMaximized         = $false
$script:PrevBounds          = $null

# ---------- Matrix state ----------
$script:MatrixRand          = New-Object System.Random
$script:MatrixColumns       = @()
$script:MatrixTimer         = $null
$script:MatrixResizeTimer   = $null

$script:MatrixChars = @(
  '0','1','2','3','4','5','6','7','8','9',
  'A','B','C','D','E','F','G','H','J','K','L','M','N','P','Q','R','S','T','U','V','W','X','Y','Z',
  '+','-','*','=','/','<','>','[',']','{','}','|','#','%','&'
)

$script:RareWords = @(
  "SYSTEM","ERROR","WAKE","OBEY","NOISE","CONTROL","SIGNAL",
  "PHASE","RESO","LINK","REVOLT","TRACE"
)

function New-MatrixStreamText {
    param([int]$minLen = 24, [int]$maxLen = 52)
    $len = $script:MatrixRand.Next($minLen, $maxLen)
    $chars = New-Object System.Collections.Generic.List[string]
    for ($i = 0; $i -lt $len; $i++) {
        $chars.Add($script:MatrixChars[$script:MatrixRand.Next(0, $script:MatrixChars.Count)])
    }
    if ($script:MatrixRand.NextDouble() -lt 0.06) {
        $word = $script:RareWords[$script:MatrixRand.Next(0, $script:RareWords.Count)]
        if ($word.Length -lt $len) {
            $start = $script:MatrixRand.Next(0, ($len - $word.Length))
            for ($j = 0; $j -lt $word.Length; $j++) {
                $chars[$start + $j] = $word[$j]
            }
        }
    }
    [string]::Join("`r`n", $chars)
}

function Initialize-Matrix {
    try {
        if (-not $MatrixCanvas -or -not $window) { return }

        $width  = if ($ClipHost) { $ClipHost.ActualWidth }  else { $window.ActualWidth }
        $height = if ($ClipHost) { $ClipHost.ActualHeight } else { $window.ActualHeight }

        if ($width -le 0 -or $height -le 0) { return }

        # Scale font size with width so fullscreen doesn't look tiny
        $fontSize = 11
        if ($width -ge 1920) {
            $fontSize = 16
        } elseif ($width -ge 1600) {
            $fontSize = 14
        } elseif ($width -ge 1280) {
            $fontSize = 12
        }

        $MatrixCanvas.Width  = $width
        $MatrixCanvas.Height = $height

        $MatrixCanvas.Children.Clear()
        $script:MatrixColumns = @()

        $colWidth = [math]::Max(9, [math]::Floor($fontSize * 0.9))

        # Cap to avoid lag: fewer, beefier columns instead of thousands of tiny ones
        $maxCols = 180
        $cols    = [math]::Ceiling($MatrixCanvas.Width / $colWidth)
        if ($cols -gt $maxCols) { $cols = $maxCols }

        for ($i = 0; $i -lt $cols; $i++) {
            $layerRoll = $script:MatrixRand.NextDouble()
            if    ($layerRoll -lt 0.30) { $layer = 'front'; $z = 3 }
            elseif($layerRoll -lt 0.75) { $layer = 'mid';   $z = 2 }
            else                        { $layer = 'back';  $z = 1 }

            $tb = New-Object System.Windows.Controls.TextBlock
            $tb.FontFamily    = 'Consolas'
            $tb.FontSize      = $fontSize
            $tb.TextAlignment = 'Center'
            $tb.LineHeight    = $fontSize * 0.9

            switch ($layer) {
                'front' {
                    $tb.Foreground = New-Object Windows.Media.SolidColorBrush (
                        [Windows.Media.ColorConverter]::ConvertFromString('#B0FF7C')
                    )
                    $tb.Opacity = 1.0
                }
                'mid' {
                    $tb.Foreground = New-Object Windows.Media.SolidColorBrush (
                        [Windows.Media.ColorConverter]::ConvertFromString('#32D46A')
                    )
                    $tb.Opacity = 0.82
                }
                'back' {
                    $tb.Foreground = New-Object Windows.Media.SolidColorBrush (
                        [Windows.Media.ColorConverter]::ConvertFromString('#0C301A')
                    )
                    $tb.Opacity = 0.52
                }
            }

            $tb.Text = New-MatrixStreamText

            $x = $i * $colWidth
            $roll = $script:MatrixRand.NextDouble()
            if ($roll -lt 0.82) {
                $y = $script:MatrixRand.Next(-80, [int]$MatrixCanvas.Height)
            } else {
                $y = -($MatrixCanvas.Height + $script:MatrixRand.Next(120,360))
            }

            [System.Windows.Controls.Canvas]::SetLeft($tb, $x)
            [System.Windows.Controls.Canvas]::SetTop($tb, $y)
            [System.Windows.Controls.Panel]::SetZIndex($tb, $z)
            [void]$MatrixCanvas.Children.Add($tb)

            switch ($layer) {
                'front' { $baseSpeed = $script:MatrixRand.NextDouble() * 4.0 + 5.8 }
                'mid'   { $baseSpeed = $script:MatrixRand.NextDouble() * 3.2 + 3.8 }
                'back'  { $baseSpeed = $script:MatrixRand.NextDouble() * 2.2 + 2.2 }
            }

            $jitter = $script:MatrixRand.NextDouble() * 0.6

            $script:MatrixColumns += [pscustomobject]@{
                X         = $x
                Y         = $y
                Speed     = $baseSpeed
                Jitter    = $jitter
                TextBlock = $tb
                Layer     = $layer
                TickMod   = $script:MatrixRand.Next(4,11)
            }
        }

        Write-ErrorLog "Matrix initialized for ${width}x${height}, fontSize=$fontSize, cols=$cols."
    } catch {
        Write-ErrorLog "Initialize-Matrix error: $($_.Exception.Message)"
    }
}

function Reset-LogToInitial {
    if (-not $LogBox -or -not $LogScroll) { return }
    $window.Dispatcher.Invoke([Action]{
        try {
            if ($LogBox.Inlines) {
                $LogBox.Inlines.Clear()
            }
            $LogBox.Text = $script:InitialLogText
            $LogScroll.ScrollToHome()
        } catch {
            Write-ErrorLog "Reset-LogToInitial UI error: $($_.Exception.Message)"
        }
    })
    $script:WelcomeCleared = $false
    Set-Status "Live feed online. Awaiting your choice..." $true
}

Reset-LogToInitial

# ---------- Loaded ----------
$window.Add_Loaded({
    param($s,$e)
    try {
        try {
            $bgmPath = Join-Path $ScriptRootSafe 'RoarMatrix_HalloweenMotivational.mp3'
            if ($BGM -and (Test-Path $bgmPath)) {
                $BGM.Source = $bgmPath
                $BGM.add_MediaEnded({
                    $BGM.Position = [TimeSpan]::Zero
                    $BGM.Play()
                })
                $BGM.Play()
            }
        } catch {
            Write-ErrorLog "BGM init failed: $($_.Exception.Message)"
        }

        try {
            if ($LiveFeed -and (Test-Path $LiveFeedPath)) {
                $LiveFeed.Source     = $LiveFeedPath
                $LiveFeed.Visibility = 'Visible'
                $LiveFeed.add_MediaEnded({
                    $LiveFeed.Position = [TimeSpan]::Zero
                    $LiveFeed.Play()
                })
                $LiveFeed.Play()
                Set-Status "Live feed online. Awaiting your choice..." $true
                Write-ErrorLog "Live feed started."
            } else {
                Write-ErrorLog "Live feed not started (missing video.mp4 or control)."
            }
        } catch {
            Write-ErrorLog "LiveFeed init failed: $($_.Exception.Message)"
        }

        Initialize-Matrix

        if (-not $script:MatrixTimer) {
            $script:MatrixTimer = New-Object System.Windows.Threading.DispatcherTimer
            $script:MatrixTimer.Interval = [TimeSpan]::FromMilliseconds(16)

            $tick = 0
            $script:MatrixTimer.Add_Tick({
                $tick++
                if (-not $MatrixCanvas) { return }
                $h = $MatrixCanvas.ActualHeight
                if ($h -le 0) { return }

                foreach ($col in $script:MatrixColumns) {
                    $delta = $col.Speed + (($script:MatrixRand.NextDouble() - 0.5) * $col.Jitter)
                    if ($delta -lt 1.4) { $delta = 1.4 }
                    $col.Y += $delta

                    if ($script:MatrixRand.NextDouble() -lt 0.002) {
                        $col.Y -= ($script:MatrixRand.Next(6,14))
                    }

                    if (($tick % $col.TickMod) -eq 0) {
                        $p = switch ($col.Layer) {
                            'front' { 0.12 }
                            'mid'   { 0.07 }
                            default { 0.03 }
                        }
                        if ($script:MatrixRand.NextDouble() -lt $p) {
                            $col.TextBlock.Text = New-MatrixStreamText
                        }
                    }

                    if ($col.Y -gt $h + 160) {
                        $col.Y = -$script:MatrixRand.Next(60,260)
                        switch ($col.Layer) {
                            'front' { $col.Speed = $script:MatrixRand.NextDouble() * 4.0 + 5.8 }
                            'mid'   { $col.Speed = $script:MatrixRand.NextDouble() * 3.2 + 3.8 }
                            'back'  { $col.Speed = $script:MatrixRand.NextDouble() * 2.2 + 2.2 }
                        }
                        $col.TextBlock.Text = New-MatrixStreamText
                    }

                    $base = switch ($col.Layer) {
                        'front' { 0.9 }
                        'mid'   { 0.7 }
                        default { 0.5 }
                    }
                    $j = $script:MatrixRand.NextDouble() * 0.18
                    $val = $base + $j
                    if ($val -gt 1.0) { $val = 1.0 }
                    $col.TextBlock.Opacity = $val

                    [System.Windows.Controls.Canvas]::SetTop($col.TextBlock, $col.Y)
                }
            })

            $script:MatrixTimer.Start()
        }

        # Rounded clip that follows size
        try {
            if ($ClipHost) {
                $updateClip = {
                    param($sender, $args)
                    $window.Dispatcher.Invoke([Action]{
                        try {
                            $clip = New-Object System.Windows.Media.RectangleGeometry
                            $clip.RadiusX = 20
                            $clip.RadiusY = 20
                            $clip.Rect = New-Object System.Windows.Rect(
                                0,
                                0,
                                [math]::Max(0, $ClipHost.ActualWidth),
                                [math]::Max(0, $ClipHost.ActualHeight)
                            )
                            $ClipHost.Clip = $clip
                        } catch {
                            Write-ErrorLog "Clip update failed: $($_.Exception.Message)"
                        }
                    })
                }
                & $updateClip $null $null
                $window.Add_SizeChanged($updateClip)
            }
        } catch {
            Write-ErrorLog "Rounded clip apply failed: $($_.Exception.Message)"
        }

        Write-ErrorLog "Loaded handler completed."
    } catch {
        Write-ErrorLog "Loaded handler error: $($_.Exception.Message)"
    }
})

# ---------- Resize: debounce Matrix rebuild ----------
$window.Add_SizeChanged({
    param($s,$e)
    try {
        if (-not $script:MatrixResizeTimer) {
            $script:MatrixResizeTimer = New-Object System.Windows.Threading.DispatcherTimer
            $script:MatrixResizeTimer.Interval = [TimeSpan]::FromMilliseconds(220)
            $script:MatrixResizeTimer.Add_Tick({
                try {
                    $script:MatrixResizeTimer.Stop()
                    $script:MatrixResizeTimer = $null
                    Initialize-Matrix
                } catch {
                    Write-ErrorLog "MatrixResizeTimer tick error: $($_.Exception.Message)"
                }
            })
        }
        $script:MatrixResizeTimer.Stop()
        $script:MatrixResizeTimer.Start()
    } catch {
        Write-ErrorLog "SizeChanged debounce failed: $($_.Exception.Message)"
    }
})

# ---------- Closed ----------
$window.Add_Closed({
    try {
        if ($script:MatrixTimer)       { $script:MatrixTimer.Stop() }
        if ($script:MatrixResizeTimer) { $script:MatrixResizeTimer.Stop() }
        if ($BGM)      { $BGM.Stop() }
        if ($LiveFeed) { $LiveFeed.Stop() }
        Write-ErrorLog "Window closed cleanly."
    } catch {
        Write-ErrorLog "Closed handler error: $($_.Exception.Message)"
    }
})

# ---------- Helpers ----------
function Clear-WelcomeIfNeeded {
    if (-not $script:WelcomeCleared -and $LogBox) {
        $window.Dispatcher.Invoke([Action]{
            try {
                if ($LogBox.Inlines) {
                    $LogBox.Inlines.Clear()
                } else {
                    $LogBox.Text = ""
                }
            } catch {
                $LogBox.Text = ""
            }
        })
        $script:WelcomeCleared = $true
    }
}

function Append-Log {
    param(
        [string]$msg,
        [ValidateSet('LOG','OK','ERR')][string]$kind='LOG'
    )

    if (-not $LogBox -or -not $LogScroll) {
        Write-ErrorLog "Append-Log: controls missing: $msg"
        return
    }

    Clear-WelcomeIfNeeded

    $ts = (Get-Date).ToString('HH:mm:ss')
    switch ($kind) {
        'OK'  { $prefix = '[OK ]';  $hex = '#5CFF7C' }
        'ERR' { $prefix = '[ERR]';  $hex = '#FF5F5F' }
        default { $prefix = '[LOG]'; $hex = '#5CFF7C' }
    }

    $text = "$ts $prefix $msg"

    $window.Dispatcher.Invoke([Action]{
        try {
            if ($LogBox.Inlines) {
                $run = New-Object Windows.Documents.Run($text + "`r`n")
                $brush = New-Object Windows.Media.SolidColorBrush (
                    [Windows.Media.ColorConverter]::ConvertFromString($hex)
                )
                $run.Foreground = $brush
                [void]$LogBox.Inlines.Add($run)
            } else {
                $LogBox.Text += $text + "`r`n"
            }
            $LogScroll.ScrollToEnd()
        } catch {
            Write-ErrorLog "Append-Log UI error: $($_.Exception.Message)"
        }
    })

    if ($kind -eq 'ERR') {
        Write-ErrorLog $text
    }
}

function Set-Status {
    param([string]$text, [bool]$ok = $true)

    if (-not $StatusText -or -not $StatusChrome) {
        Write-ErrorLog "Set-Status: controls missing: $text"
        return
    }

    $window.Dispatcher.Invoke([Action]{
        try {
            $StatusText.Text = $text

            if ($ok) {
                $StatusText.Foreground = New-Object Windows.Media.SolidColorBrush (
                    [Windows.Media.ColorConverter]::ConvertFromString('#6BFF8A')
                )
                $StatusChrome.Background = New-Object Windows.Media.SolidColorBrush (
                    [Windows.Media.ColorConverter]::ConvertFromString('#E0000000')
                )
                $StatusChrome.BorderBrush = New-Object Windows.Media.SolidColorBrush (
                    [Windows.Media.ColorConverter]::ConvertFromString('#26FF6A')
                )
            } else {
                $StatusText.Foreground = New-Object Windows.Media.SolidColorBrush (
                    [Windows.Media.ColorConverter]::ConvertFromString('#FF5F5F')
                )
                $StatusChrome.Background = New-Object Windows.Media.SolidColorBrush (
                    [Windows.Media.ColorConverter]::ConvertFromString('#80000000')
                )
                $StatusChrome.BorderBrush = New-Object Windows.Media.SolidColorBrush (
                    [Windows.Media.ColorConverter]::ConvertFromString('#FF5F5F')
                )
            }
        } catch {
            Write-ErrorLog "Set-Status UI error: $($_.Exception.Message)"
        }
    })
}

# ---------- Window behavior (drag to move) ----------
if ($TopBar) {
    $TopBar.Add_MouseLeftButtonDown({
        param($sender, $e)
        if ($e.LeftButton -eq [System.Windows.Input.MouseButtonState]::Pressed) {
            try {
                $window.DragMove()
            } catch {
                Write-ErrorLog "DragMove failed (TopBar): $($_.Exception.Message)"
            }
        }
    })
}

$window.Add_MouseLeftButtonDown({
    param($sender, $e)
    if ($e.LeftButton -eq [System.Windows.Input.MouseButtonState]::Pressed) {
        try {
            $window.DragMove()
        } catch {
            Write-ErrorLog "DragMove failed (Window): $($_.Exception.Message)"
        }
    }
})

# ---------- Fullscreen toggle ----------
if ($FsBtn) {
    $FsBtn.Add_Click({
        try {
            if (-not $script:IsMaximized) {
                $script:PrevBounds = @{
                    Left   = $window.Left
                    Top    = $window.Top
                    Width  = $window.Width
                    Height = $window.Height
                }
                $window.WindowState = 'Maximized'
                $script:IsMaximized = $true
                if ($FsIcon) { $FsIcon.Text = [char]0xE923 }  # Restore icon
            } else {
                $window.WindowState = 'Normal'
                if ($script:PrevBounds) {
                    $window.Left   = $script:PrevBounds.Left
                    $window.Top    = $script:PrevBounds.Top
                    $window.Width  = $script:PrevBounds.Width
                    $window.Height = $script:PrevBounds.Height
                }
                $script:IsMaximized = $false
                if ($FsIcon) { $FsIcon.Text = [char]0xE922 }  # Maximize icon
            }
            Initialize-Matrix
        } catch {
            Write-ErrorLog "FsBtn failed: $($_.Exception.Message)"
        }
    })
}

# ---------- Buttons ----------
if ($MinBtn) {
    $MinBtn.Add_Click({
        Clear-WelcomeIfNeeded
        try {
            $window.WindowState = 'Minimized'
        } catch {
            Write-ErrorLog "MinBtn failed: $($_.Exception.Message)"
        }
    })
}

if ($HomeBtn) {
    $HomeBtn.Add_Click({
        try {
            Reset-LogToInitial
        } catch {
            Write-ErrorLog "HomeBtn failed: $($_.Exception.Message)"
        }
    })
}

if ($ExitBtn) {
    $ExitBtn.Add_Click({
        Clear-WelcomeIfNeeded
        try {
            $window.Close()
        } catch {
            Write-ErrorLog "ExitBtn failed: $($_.Exception.Message)"
        }
    })
}

# ---------- Actions ----------
if ($TempBtn) {
    $TempBtn.Add_Click({
        try {
            Append-Log "Starting temp cleanup (aggressive)."
            Append-Log "RecentPath  : $RecentPath"
            Append-Log "UserTempPath: $UserTempPath"

            $targets = @(
                $RecentPath,
                (Join-Path $env:WINDIR 'Prefetch'),
                (Join-Path $env:WINDIR 'Temp'),
                $UserTempPath
            )

            $totalFiles = 0
            $totalDirs  = 0

            foreach ($path in $targets) {
                Append-Log "Scanning: $path"
                if (Test-Path $path) {
                    try {
                        Get-ChildItem -Path $path -Force -ErrorAction SilentlyContinue | ForEach-Object {
                            if ($_.PSIsContainer) {
                                try {
                                    Remove-Item -LiteralPath $_.FullName -Recurse -Force -ErrorAction Stop
                                    $totalDirs++
                                    Append-Log "Deleted folder: $($_.FullName)" 'OK'
                                } catch {
                                    Append-Log "Skipped folder (locked/in use): $($_.FullName)"
                                }
                            } else {
                                try {
                                    Remove-Item -LiteralPath $_.FullName -Force -ErrorAction Stop
                                    $totalFiles++
                                    Append-Log "Deleted file: $($_.FullName)" 'OK'
                                } catch {
                                    Append-Log "Skipped file (locked/in use): $($_.FullName)"
                                }
                            }
                        }
                    } catch {
                        Append-Log "Error processing $path -> $($_.Exception.Message)" 'ERR'
                    }
                } else {
                    Append-Log "Not found: $path" 'ERR'
                }
            }

            Append-Log "Cleanup complete: $totalFiles files, $totalDirs folders removed." 'OK'
            Set-Status ("Cleanup Done. {0} files and {1} folders removed." -f $totalFiles, $totalDirs) $true
        } catch {
            Append-Log "Temp cleanup failed: $($_.Exception.Message)" 'ERR'
            Set-Status "Cleanup failed." $false
        }
    })
}

if ($TelemetryBtn) {
    $TelemetryBtn.Add_Click({
        try {
            Append-Log "Disabling Windows telemetry vectors."
            $svc = @('DiagTrack','dmwappushservice')
            foreach ($s in $svc) {
                Append-Log "Stopping $s"
                try {
                    Stop-Service -Name $s -Force -ErrorAction Stop
                    Append-Log "Stopped $s" 'OK'
                } catch {
                    Append-Log "Stop failed: $($_.Exception.Message)" 'ERR'
                }

                Append-Log "Disabling $s"
                try {
                    Set-Service -Name $s -StartupType Disabled -ErrorAction Stop
                    Append-Log "Disabled $s" 'OK'
                } catch {
                    Append-Log "Set-Service failed: $($_.Exception.Message) -> trying sc.exe" 'ERR'
                    try {
                        sc.exe config $s start= disabled | Out-Null
                        Append-Log "Disabled via sc.exe" 'OK'
                    } catch {
                        Append-Log "sc.exe failed: $($_.Exception.Message)" 'ERR'
                    }
                }
            }

            Append-Log "Reinforcing hosts file against telemetry endpoints."
            $hosts = @(
                'telemetry.microsoft.com',
                'watson.telemetry.microsoft.com',
                'vortex-win.data.microsoft.com',
                'settings-win.data.microsoft.com'
            )
            $blocked = 0
            $hp = Join-Path $env:WINDIR 'System32\drivers\etc\hosts'
            try { attrib -R $hp 2>$null } catch { }

            $AddLine = {
                param([string]$file,[string]$line)
                $max = 10
                for ($i=1; $i -le $max; $i++) {
                    try {
                        $fs = [System.IO.File]::Open($file,
                            [System.IO.FileMode]::Open,
                            [System.IO.FileAccess]::ReadWrite,
                            [System.IO.FileShare]::ReadWrite)
                        try {
                            $sr = New-Object System.IO.StreamReader($fs,[System.Text.Encoding]::ASCII,$true,1024,$true)
                            $content = $sr.ReadToEnd()
                            $sr.Dispose()
                            if ($content -notmatch [regex]::Escape($line)) {
                                $sw = New-Object System.IO.StreamWriter($fs,[System.Text.Encoding]::ASCII,1024,$true)
                                [void]$fs.Seek(0,[System.IO.SeekOrigin]::End)
                                if (-not $content.EndsWith("`r`n")) { $sw.Write("`r`n") }
                                $sw.WriteLine($line)
                                $sw.Flush()
                                $sw.Dispose()
                                return $true
                            } else {
                                return $false
                            }
                        } finally {
                            $fs.Dispose()
                        }
                    } catch {
                        Start-Sleep -Milliseconds 300
                        if ($i -eq $max) { throw }
                    }
                }
            }

            foreach ($h in $hosts) {
                $ln = "0.0.0.0 $h"
                try {
                    $added = & $AddLine $hp $ln
                    if ($added) {
                        $blocked++
                        Append-Log "Blocked: $h" 'OK'
                    } else {
                        Append-Log "Already blocked: $h"
                    }
                } catch {
                    Append-Log "Hosts add failed: $h -> $($_.Exception.Message)" 'ERR'
                }
            }

            try { ipconfig /flushdns | Out-Null } catch { }
            Append-Log "Telemetry hardened - $blocked host entries added/confirmed." 'OK'
            Set-Status ("Telemetry reduced. {0} hosts blocked." -f $blocked) $true
        } catch {
            Append-Log "Telemetry action failed: $($_.Exception.Message)" 'ERR'
            Set-Status "Telemetry action failed." $false
        }
    })
}

if ($ShaderBtn) {
    $ShaderBtn.Add_Click({
        try {
            Append-Log "Purging GPU shader caches."
            $L = $env:LOCALAPPDATA
            $paths = @(
                (Join-Path $L 'NVIDIA\GLCache'),
                (Join-Path $L 'NVIDIA\DXCache'),
                (Join-Path $L 'NVIDIA Corporation\NV_Cache'),
                (Join-Path $L 'NVIDIA\VkCache'),
                (Join-Path $L 'D3DSCache'),
                (Join-Path $L 'Microsoft\DirectX Shader Cache'),
                (Join-Path $L 'AMD\DxCache'),
                (Join-Path $L 'AMD\DxcCache'),
                (Join-Path $L 'Intel\ShaderCache')
            )
            $cleared = 0
            foreach ($p in $paths) {
                if (Test-Path $p) {
                    try {
                        Get-ChildItem $p -Recurse -Force -ErrorAction SilentlyContinue |
                            Remove-Item -Force -Recurse -ErrorAction SilentlyContinue
                        Append-Log "Cleared: $p" 'OK'
                        $cleared++
                    } catch {
                        Append-Log "Skip: $p -> $($_.Exception.Message)" 'ERR'
                    }
                } else {
                    Append-Log "Not found: $p"
                }
            }
            Append-Log "Shader cache purge complete: $cleared cache locations cleared." 'OK'
            Set-Status ("Shader cache cleared. {0} caches purged." -f $cleared) $true
        } catch {
            Append-Log "Shader cache clear failed: $($_.Exception.Message)" 'ERR'
            Set-Status "Shader cache clear failed." $false
        }
    })
}

if ($NetBtn) {
    $NetBtn.Add_Click({
        try {
            Append-Log "Initiating Net Refresh (DNS, ARP, Winsock)."
            $errs = 0

            try {
                Append-Log "Flushing DNS cache..."
                ipconfig /flushdns | Out-Null
                Append-Log "DNS cache flushed." 'OK'
            } catch {
                $errs++
                Append-Log "DNS flush failed: $($_.Exception.Message)" 'ERR'
            }

            try {
                Append-Log "Clearing ARP cache..."
                arp -d * | Out-Null
                Append-Log "ARP cache cleared." 'OK'
            } catch {
                $errs++
                Append-Log "ARP clear failed: $($_.Exception.Message)" 'ERR'
            }

            try {
                Append-Log "Resetting Winsock..."
                netsh winsock reset | Out-Null
                Append-Log "Winsock reset completed." 'OK'
            } catch {
                $errs++
                Append-Log "Winsock reset failed: $($_.Exception.Message)" 'ERR'
            }

            if ($errs -eq 0) {
                Append-Log "Net Refresh Completed. Reboot Recommended." 'OK'
                Set-Status "Net Refresh Completed. Reboot Recommended." $true
            } else {
                Append-Log "Net Refresh completed with $errs error(s). Check LIVE LOG overlay." 'ERR'
                Set-Status "Net Refresh completed with errors." $false
            }
        } catch {
            Append-Log "Net Refresh failed: $($_.Exception.Message)" 'ERR'
            Set-Status "Net Refresh failed." $false
        }
    })
}

if ($PowerBtn) {
    $PowerBtn.Add_Click({
        try {
            Append-Log "Creating and activating high performance power plan."

            # Duplicate the High Performance scheme (GUID: 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c)
            $output = powercfg -duplicatescheme 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c

            # Parse the new GUID from output
            if ($output -match "Power Scheme GUID: (\w{8}-\w{4}-\w{4}-\w{4}-\w{12})") {
                $newGuid = $matches[1]

                Append-Log "New plan GUID: $newGuid" 'OK'

                # Set the new plan as active
                powercfg -setactive $newGuid

                Append-Log "High performance plan activated." 'OK'
                Set-Status "High performance plan created and activated." $true
            } else {
                Append-Log "Failed to parse new GUID from powercfg output." 'ERR'
                Set-Status "Power plan creation failed." $false
            }
        } catch {
            Append-Log "Power plan action failed: $($_.Exception.Message)" 'ERR'
            Set-Status "Power plan action failed." $false
        }
    })
}

# ---------- Show window ----------
try {
    $null = $window.ShowDialog()
} catch {
    Write-ErrorLog "ShowDialog failed: $($_.Exception.Message)"
}