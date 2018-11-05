function Get-AstRule
{
    <#
        .Synopsis
        Gets a rendering rule for a specific AST object

        .Example
        Get-AstRule -Name 'IfStatementAst'

        .Notes
        Most AST items have very generic rules.
    #>
    [cmdletbinding()]
    param(
        # AST object type name
        [Parameter(
            Mandatory,
            Position = 0,
            ValueFromPipelineByPropertyName
        )]
        [ValidateNotNullOrEmpty()]
        [String]
        $Name
    )

    begin
    {
        $astRules = @{
            ScriptBlockExpressionAst      = @{
                ChildProperty = 'ScriptBlock'
                Label         = {'ScriptBlock'}
                Visible       = $false
            }
            CommandExpressionAst          = @{
                ChildProperty = 'Expression'
                Label         = {'CommandExpression'}
                Visible       = $false
            }
            ConstantExpressionAst         = @{
                Visible = $true
                Label   = {$_.Value}
            }
            NamedBlockAst                 = @{
                Visible       = $true
                ChildProperty = 'Statements'
                Label         = {'{0} Block' -f $_.BlockKind}
            }
            VariableExpressionAst         = @{
                Visible = $true
                Label   = {$_.extent.tostring()}
            }
            AssignmentStatementAst        = @{
                Visible       = $true
                Label         = {("{0} {1}" -f $_.left.ToString(), $_.Operator)}
                ChildProperty = 'Right'
            }
            UnaryExpressionAst            = @{
                Visible = $true
                Label   = {$_.extent.tostring()}
            }
            CommandParameterAst           = @{
                Visible = $true
                Label   = {"-$($_.ParameterName)"}
            }
            ScriptBlockAst                = @{
                Visible       = $false
                ChildProperty = 'ParamBlock', 'BeginBlock', 'ProcessBlock', 'EndBlock'
                Label         = {'ScriptBlock'}
            }
            MemberExpressionAst           = @{
                Visible = $true
                Label   = {$_.extent.tostring()}
            }
            InvokeMemberExpressionAst     = @{
                Visible = $true
                Label   = {$_.extent.tostring()}
            }
            ArrayExpressionAst            = @{
                Visible       = $false
                Label         = '[System.Object[]]::New()@{'
                ChildProperty = 'SubExpression'
            }
            StringConstantExpressionAst   = @{
                Visible = $true
                Label   = { "{0}" -f $_.extent.tostring() }
            }
            ExpandableStringExpressionAst = @{
                Visible       = $true
                Label         = {$_.extent.tostring()}
                ChildProperty = 'NestedExpressions'
            }
            IndexExpressionAst            = @{
                Visible = $true
                Label   = {$_.extent.tostring()}
            }
            ThrowStatementAst             = @{
                Visible = $true
                Label   = {$_.extent.tostring()}
            }
            CmdletInfo                    = {
                Visible = $true
                Label = {$_.Name}
            }
            _HashtableAst                 = @{
                Visible       = $true
                Label         = {'Hashtable'}
                ChildProperty = 'KeyValuePairs'
            }
            'Tuple`2'                     = @{
                Visible       = $true
                Label         = {$_.Item1}
                ChildProperty = 'Item1', 'Item2'
            }
            ParenExpressionAst            = @{
                Visible       = $false
                Label         = {'ParenExpression'}
                ChildProperty = 'Pipeline'
            }
            _IfStatementAST               = @{
                Visible       = $true
                Label         = 'IF'
                ChildProperty = 'Clauses', 'ElseClause'
            }
            StatementBlockAst             = @{
                Visible       = $false
                Label         = 'StatementBlock'
                ChildProperty = 'Statements'
            }
            BinaryExpressionAST           = @{
                Visible       = $true
                Label         = {$_.Operator}
                ChildProperty = 'Left', 'Right'
            }
            ForEachStatementAst           = @{
                Visible       = $true
                Label         = {'{0} foreach ( {1} in {2} )' -f $_.Label, $_.Variable, $_.Condition}
                ChildProperty = 'Condition', 'Body'
                #Container = 'Condition'
            }
            FunctionDefinitionAST         = @{
                Visible       = $true
                Label         = {$_.Name}
                ChildProperty = 'Parameters', 'Body'
            }
            SwitchStatementAST            = @{
                Visible       = $true
                Label         = {'{0} Switch ( {1} )' -f $_.Label, $_.Condition}
                ChildProperty = 'Condition', 'Clauses', 'Default'
            }
            TryStatementAST               = @{
                Visible       = $true
                Label         = 'TRY'
                ChildProperty = 'Body', 'CatchClauses', 'Finally'
            }
            CatchClauseAst                = @{
                Visible       = $true
                Label         = 'CATCH'
                ChildProperty = 'CatchTypes', 'Body'
            }
            DoUntilStatementAst           = @{
                Visible       = $true
                Label         = {'{0} DO UNTIL ( {1} )' -f $_.label, $_.Condition}
                ChildProperty = 'Condition', 'Body'
            }
            ReturnStatementAst            = @{
                Visible       = $true
                Label         = 'RETURN'
                ChildProperty = 'Pipeline'
            }
            SubExpressionAst              = @{
                Visible       = $false
                Label         = 'SubExpression'
                ChildProperty = 'SubExpression'
            }
            ArrayLiteralAst               = @{
                Visible = $true
                Label   = {$_.extent.tostring()}
                #ChildProperty = 'Elements'
            }
            ContinueStatementAst          = @{
                Visible = $true
                Label   = {$_.extent.tostring()}
            }
            BreakStatementAst             = @{
                Visible = $true
                Label   = {$_.extent.tostring()}
            }
            ConvertExpressionAst          = @{
                Visible       = $true
                Label         = {$_.type.extent.tostring()}
                ChildProperty = 'Child'
            }
            WhileStatementAst             = @{
                Visible       = $true
                Label         = {'{0} WHILE ( {1} )' -f $_.Label, $_.Condition}
                ChildProperty = 'Condition', 'Body'
            }
            TypeDefinitionAst             = @{
                Visible       = $true
                Label         = {'{0} {1}' -f $_.TypeAttributes, $_.Name}
                ChildProperty = 'Attributes', 'Members'
            }
            PropertyMemberAst             = @{
                Visible       = $true
                Label         = {$_.extent.tostring()}
                ChildProperty = 'InitialValue'
            }
            TypeConstraintAst             = @{
                Visible       = $true
                Label         = {$_.extent.tostring()}
                ChildProperty = 'InitialValue'
            }
            ParameterAst                  = @{
                Visible       = $true
                Label         = {$_.Name}
                ChildProperty = 'Attributes', 'DefaultValue'
            }
            AttributeAst                  = @{
                Visible       = $true
                Label         = {'[{0}( ... )]' -f $_.TypeName}
                ChildProperty = 'NamedArguments', 'PositionalArguments'
            }
            NamedAttributeArgumentAst     = @{
                Visible       = $true
                Label         = {$_.ArgumentName}
                ChildProperty = 'Argument'
            }
            FunctionMemberAst             = @{
                Visible       = $true
                Label         = {'{0} {1}' -f $_.ReturnType, $_.Name}
                ChildProperty = 'Attributes', 'Parameters', 'Body'
            }
            ParamBlockAst                 = @{
                Visible       = $true
                Label         = 'Param (...)'
                ChildProperty = 'Parameters'
            }
            ForStatementAst               = @{
                Visible       = $true
                Label         = {'{0} FOR ( {1}; {2}; {3})' -f $_.Label, $_.Initializer, $_.Condition, $_.Iterator}
                ChildProperty = 'Condition', 'Body'
            }
        }
    }

    process
    {
        try
        {
            $astRules[$Name]
        }
        catch
        {
            $PSCmdlet.ThrowTerminatingError( $PSItem )
        }
    }
}
