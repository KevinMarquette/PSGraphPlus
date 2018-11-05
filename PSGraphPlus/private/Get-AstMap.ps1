function Get-AstMap
{
    [cmdletbinding()]
    param (
        [Parameter(
            ValueFromPipeline,
            Position = 0
        )]
        [AllowNull()]
        $Ast,

        $ParentID = $null,

        [ref]$ChildId = [ref]$null
    )

    process
    {
        $lastId = $null
        $rank = [System.Collections.Generic.List[System.Object]]::new()
        :node foreach ($node in $Ast)
        {
            $type = $node.GetType().Name
            $id = $node.gethashcode()

            $rule = Get-AstRule -Name $type
            if ($rule)
            {
                if ($rule.Visible -or $Script:DebugAST -eq $true)
                {
                    Add-DebugNote -Id $id -Message $type
                    $ChildId.Value = $id
                    if ( $rule.Container )
                    {
                        throw 'not supported, subgraphs are buggy with these types of graphs'
                        subgraph -Name $id -Attributes @{label = $rule.Label; labeljust = 'l'} -scriptblock {
                            Get-AstMap -AST $node.$($rule.Container)
                        }
                    }
                    else
                    {
                        $node | node -NodeScript {$id} -Attributes @{label = $rule.Label}
                    }
                    foreach ( $property in $rule.ChildProperty )
                    {
                        Get-AstMap -AST $node.$property -ParentID $id
                    }
                }
                else
                {
                    $ChildId.Value = $id
                    foreach ( $property in $rule.ChildProperty )
                    {
                        Get-AstMap -AST $node.$property -ParentID $ParentID -ChildId $ChildId
                    }
                    continue node
                }
            }
            else
            {
                # hand crafted rules
                switch ( $type )
                {
                    'ForStatementAst'
                    {
                        $node
                    }
                    'IfStatementAST'
                    {
                        Add-DebugNote -Id $id -Message $type
                        $ChildId.Value = $id
                        node -Name $id @{label = "IF (...)"; color = 'blue'}
                        $conditionID = New-Guid
                        $conditionTrueID = new-guid
                        node -Name $conditionID @{label = '( CONDITION )'; color = 'blue'; }
                        Edge $id -To $conditionID
                        Get-AstMap -AST $node.Clauses[0].Item1 -ParentID $conditionID
                        node -Name $conditionTrueID @{label = 'IF TRUE'; color = 'blue'; shape = 'diamond'}
                        Edge $id -To $conditionTrueID
                        Get-AstMap -AST $node.Clauses[0].Item2 -ParentID $conditionTrueID

                        $NextParent = $id
                        $list = $node.Clauses

                        for ($index = 1; $index -lt $list.count; $index++ )
                        {
                            $child = $node.Clauses[$index]
                            $ifElseID = New-Guid
                            $conditionID = New-Guid
                            $conditionTrueID = new-guid
                            node -Name $ifElseID @{label = "IFELSE (...)"; color = 'blue'}
                            edge $NextParent -To $ifElseID
                            node -Name $conditionID @{label = '( CONDITION )'; color = 'blue'; }
                            Edge $ifElseID -To $conditionID

                            Get-AstMap -AST $child.Item1 -ParentID $conditionID
                            node -Name $conditionTrueID @{label = 'IF TRUE'; color = 'blue'; shape = 'diamond'}
                            Edge $ifElseID -To $conditionTrueID

                            Get-AstMap -AST $child.Item2 -ParentID $conditionTrueID

                            $NextParent = $ifElseID
                        }

                        $child = $node.ElseClause
                        if ( $child )
                        {
                            $elseId = New-Guid
                            $conditionID = New-Guid
                            $conditionTrueID = new-guid
                            node -Name $elseId @{label = "ELSE"; color = 'blue'; shape = 'diamond'}
                            edge $NextParent -To $elseId
                            Get-AstMap -AST $child -ParentID $elseId
                        }
                        #continue node
                    }
                    'HashtableAst'
                    {
                        Add-DebugNote -Id $id -Message $type
                        $ChildId.Value = $id
                        node -Name $id @{label = '@{...}'}
                        foreach ($child in $node.KeyValuePairs)
                        {
                            $NextParent = 0
                            Get-AstMap -AST $child.Item1 -ParentID $id -ChildId ([ref]$NextParent)
                            Get-AstMap -AST $child.Item2 -ParentID $NextParent
                        }
                        #$node
                    }
                    'CommandAst'
                    {
                        #CommandElements
                        $property = 'CommandElements'
                        if ($node.$($property).count )
                        {
                            $ChildId.Value = $id
                            $child = $node.$($property)[0]
                            Get-AstMap -AST $child -ParentID $ParentId -ChildId $ChildId
                            Add-DebugNote -Id $ChildId.Value -Message $type
                        }

                        $command = Get-Command -Name $child.Value -ErrorAction Ignore

                        $PrimaryParent = $ChildId.Value
                        $NewParent = $ChildId.Value
                        $NextParent = $ChildId.Value
                        $list = $node.$($property)

                        for ($index = 1; $index -lt $list.count; $index++ )
                        {
                            $child = $node.$($property)[$index]
                            Get-AstMap -AST $child -ParentID $NewParent -ChildId ([ref]$NextParent)

                            $NewParent = $PrimaryParent
                            if ( $child.GetType().name -eq 'CommandParameterAst' -and
                                -not $command.Parameters.$($child.ParameterName).SwitchParameter
                            )
                            {
                                $NewParent = $NextParent
                            }
                        }
                        continue node
                    }
                    'PipelineAst'
                    {
                        $NextParent = $ParentID
                        if ($Script:DebugAST)
                        {
                            $ChildId.Value = $id
                            node -Name $id @{label = 'PipelineAst[]'}
                            edge $ParentID -To $id
                            $NextParent = $id
                        }

                        $ChildId.Value = $id
                        Get-AstMap -AST $node.PipelineElements[0] -ParentID $NextParent -ChildId $ChildId
                        Add-DebugNote -Id $ChildId.Value -Message $type

                        $NewParent = $ChildId.Value
                        $NextParent = $ChildId.Value
                        $list = $node.PipelineElements
                        for ($index = 1; $index -lt $list.count; $index++ )
                        {
                            if ( $index -lt $list.count )
                            {
                                $guid = New-Guid
                                node -Name $guid @{label = "|"}
                                edge $NewParent -To $guid
                                $NewParent = $guid
                            }
                            Get-AstMap -AST $node.PipelineElements[$index] -ParentID $NewParent -ChildId ([ref]$NextParent)
                            Add-DebugNote -Id $NextParent -Message $type

                            $NewParent = $NextParent
                        }

                        continue node
                    }

                    default
                    {
                        $ChildId.Value = $id
                        node -Name $id @{label = $type; color = 'red'}
                        $guid = New-Guid
                        node -Name $guid @{label = $node.extent.tostring()}
                        edge $id -to $guid
                        #Write-Host "Skipping type [$PSItem]"
                        #continue node
                    }
                }
            }
            if ($null -ne $lastId)
            {
                #edge $lastId -to $id
            }
            $rank.Add($id)
            $lastId = $id
            if ( $null -ne $ParentId )
            {
                edge $ParentId -to $id
            }
        }
        if ($rank.Count -gt 1)
        {
            #edge -From $rank -LiteralAttribute '[style="invis"]'
            rank -Nodes $rank
        }
    }
}
