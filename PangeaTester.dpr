program PangeaTester;
{

  Delphi DUnit Test Project
  -------------------------
  This project contains the DUnit test framework and the GUI/Console test runners.
  Add "CONSOLE_TESTRUNNER" to the conditional defines entry in the project options
  to use the console test runner.  Otherwise the GUI test runner will be used by
  default.

}

{$IFDEF CONSOLE_TESTRUNNER}
{$APPTYPE CONSOLE}
{$ENDIF}

uses
  DUnitX.Loggers.Text,
  DUnitX.Loggers.XML.NUnit,
  DUnitX.Loggers.XML.xUnit,
  DUnitX.Test,
  DUnitX.TestFixture,
  DUnitX.TestFramework,
  DUnitX.TestResult,
  DUnitX.RunResults,
  DUnitX.TestRunner,
  DUnitX.Utils.XML,
  DUnitX.WeakReference,
  DUnitX.Windows.Console,
  DUnitX.StackTrace.EurekaLog7,
  DUnitX.Loggers.Null,
  DUnitX.MemoryLeakMonitor.Default,
  DUnitX.AutoDetect.Console,
  DUnitX.ConsoleWriter.Base,
  DUnitX.DUnitCompatibility,
  DUnitX.Extensibility,
  DUnitX.Extensibility.PluginManager,
  DUnitX.FixtureProviderPlugin,
  DUnitX.FixtureResult,
  DUnitX.Generics,
  DUnitX.InternalInterfaces,
  DUnitX.IoC,
  DUnitX.Loggers.Console,
  DUnitX.CommandLine.OptionDef,
  DUnitX.CommandLine.Options,
  DUnitX.CommandLine.Parser,
  DUnitX.OptionsDefinition,
  DUnitX.Banner,
  DUnitX.CategoryExpression,
  DUnitX.TestNameParser,
  DUnitX.FilterBuilder,
  DUnitX.Filters,
  DUnitX.Assert,
  DUnitX.Utils,
  DUnitX.Attributes,
  DUnitX.Types,
  DUnitX.Timeout,
  System.SysUtils,
  TestScopeAction in 'tests\TestScopeAction.pas',
  TestTuple in 'tests\TestTuple.pas',
  TestMemoryGuard in 'tests\TestMemoryGuard.pas',
  TestOptional in 'tests\TestOptional.pas',
  Pangea.ScopeAction in 'source\Pangea.ScopeAction.pas',
  Pangea.Tuple in 'source\Pangea.Tuple.pas',
  Pangea.MemoryGuard in 'source\Pangea.MemoryGuard.pas',
  Pangea.Optional in 'source\Pangea.Optional.pas',
  Pangea.Pipeline.Range in 'source\Pangea.Pipeline.Range.pas',
  Pangea.Pipeline.ArrayRange in 'source\Pangea.Pipeline.ArrayRange.pas',
  Pangea.Pipeline.ListRange in 'source\Pangea.Pipeline.ListRange.pas',
  Pangea.Pipeline in 'source\Pangea.Pipeline.pas',
  TestPipeline in 'tests\TestPipeline.pas',
  Pangea.Pipeline.ExecutionPolicy in 'source\Pangea.Pipeline.ExecutionPolicy.pas',
  Pangea.Pipeline.ExecutionPolicy.Parallel in 'source\Pangea.Pipeline.ExecutionPolicy.Parallel.pas';

{$R *.RES}

var
  LRunner : ITestRunner;
  LResults : IRunResults;
  LLogger : ITestLogger;
begin
  try
    TDUnitX.CheckCommandLine();

    //Create the runner
    LRunner := TDUnitX.CreateRunner();
    LRunner.UseRTTI := True;
    //tell the runner how we will log things
    LLogger := TDUnitXConsoleLogger.Create(false);
    LRunner.AddLogger(LLogger);

    //Run tests
    LResults := LRunner.Execute();
    if not LResults.AllPassed then
      System.ExitCode := EXIT_ERRORS;

    if TDUnitX.Options.ExitBehavior = TDUnitXExitBehavior.Pause then
    begin
      System.Write('Done.. press <Enter> key to quit.');
      System.Readln;
    end;

  except
    on E: Exception do
      System.Writeln(E.ClassName, ': ', E.Message);
  end;
end.

