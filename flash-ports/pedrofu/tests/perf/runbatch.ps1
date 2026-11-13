param([string]$Snap,[string]$LogDir,[int]$Concurrency,[string[]]$Specs)
# Each spec: name|script|args(space separated)
$root='E:\AI Stuff\Calc Stuff'
New-Item -ItemType Directory $LogDir -Force | Out-Null
$queue=[System.Collections.Queue]::new(); foreach($s in $Specs){$queue.Enqueue($s)}
$running=@(); $results=@()
while($queue.Count -gt 0 -or $running.Count -gt 0){
  while($queue.Count -gt 0 -and $running.Count -lt $Concurrency){
    $spec=$queue.Dequeue().Split('|'); $name=$spec[0]; $script=$spec[1]; $extra=if($spec.Count -gt 2 -and $spec[2]){$spec[2].Split(' ')}else{@()}
    $out="$LogDir\$name.txt"
    $p=Start-Process -FilePath python -ArgumentList (@("flash-ports/$Snap/tests/$script.py")+$extra) -WorkingDirectory $root -NoNewWindow -PassThru -RedirectStandardOutput $out -RedirectStandardError "$out.err"
    try{$p.PriorityClass='Idle'}catch{}
    $running+=[pscustomobject]@{name=$name;proc=$p}
  }
  Start-Sleep -Seconds 3
  $still=@(); foreach($r in $running){ if($r.proc.HasExited){$results+=[pscustomobject]@{name=$r.name;exit=$r.proc.ExitCode}}else{$still+=$r} }
  $running=$still
}
$results | ForEach-Object { "{0,-34} exit {1}" -f $_.name,$_.exit }
