#INCLUDE 'Totvs.ch'
#INCLUDE 'Fwmvcdef.ch'


/*/{Protheus.doc} User Function AluMvc
    Mvc referente aos instrutores
    @type  Function
    @author Vinícius Silva
    @since 27/03/2023
/*/
User Function AluMvc()
    Local cAlias := "ZZE"
    Local cTitle := "Cadastro de Alunos"
    Local oMark   := FwMarkBrowse():New()

    oMark:SetAlias(cAlias)
    oMark:SetDescription(cTitle)
    oMark:SetFieldMark("ZZE_MARC")

    oMark:AddButton("Excluir Marcados", "U_Deleta"  , 5, 1)

    oMark:DisableDetails()
    oMark:DisableReport()
    oMark:Activate()
Return 

Static Function MenuDef()
    Local aRotina := {}

    ADD OPTION aRotina TITLE "Incluir" ACTION "VIEWDEF.AluMvc" OPERATION 3 ACCESS 0
    ADD OPTION aRotina TITLE "Alterar" ACTION "VIEWDEF.AluMvc" OPERATION 4 ACCESS 0
    ADD OPTION aRotina TITLE "Excluir" ACTION "VIEWDEF.AluMvc" OPERATION 5 ACCESS 0
    
Return aRotina

Static Function ModelDef()
    //? Validações do Modelo
    Local bModelPos := {|oModel| VldAul(oModel)}

    Local oModel   := MPFormModel():New("AluMvc_M", , bModelPos)
    Local oStruZZE := FWFormStruct(1, "ZZE")

    oModel:AddFields("ZZEMASTER",,oStruZZE)
    oStruZZE:SetProperty("ZZE_CODIGO", MODEL_FIELD_INIT, FwBuildFeature(STRUCT_FEATURE_INIPAD,  "GETSXENUM('ZZE', 'ZZE_CODIGO')"))

    oModel:SetPrimaryKey({"ZZE_CODIGO"})

Return oModel

Static Function ViewDef()
    Local oModel   := FwLoadModel("AluMvc") 
    Local oStruZZE := FWFormStruct(2, "ZZE")
    Local oView    := FwFormView():New()

    oView:SetModel(oModel) 
    oView:AddField("VIEW_ZZE", oStruZZE, "ZZEMASTER")
    oView:CreateHorizontalBox("Tela", 100)
    oView:SetOwnerView("VIEW_ZZE", "Tela")

Return oView

User Function Deleta()
    if MsgYesNo("Você deseja fazer a exclusão desse aluno?")
        DbSelectArea("ZZE")

        ZZE->(DbGoTop())

        while ZZE->(!EOF())
            if ZZE_AULA == "Não"
                if oMark:IsMark()
                    RecLock("ZZE", .F.)
                        ZZE->(DbDelete())
                    ZZE->(MsUnlock())
                endif 
            elseif ZZE_AULA == "Sim"
                Help(Nil, Nil, "Não autorizado!", Nil, "Esse aluno ainda está tendo aulas", 1, 0, Nil, Nil, Nil, Nil, Nil, {"Espere o aluno encerrar as aulas."}) 
            endif 
            ZZE->(DbSkip())
        end
    endif

    oMark:Refresh(.T.)
Return 

Static Function VldAul(oModel)
    //? Variaveis para trabalhar com as incrementações da quant de alunos
    Local lRet     := .T.
    LocaL lAluMax  := .F.
    Local nOper    := oModel:GetOperation()
    Local cCodInst := oModel:GetValue("ZZEMASTER", "ZZE_CODINS")
    
    //? Variáveis para validação do instrutor não preenchido 
    Local cTemInst := AllTrim(oModel:GetValue("ZZEMASTER", "ZZE_CODINS"))
    Local cTemAula := AllTrim(oModel:GetValue("ZZEMASTER", "ZZE_AULA"))    

    //? Parte para fazer as incrementações da quantidade de alunos
    DbSelectArea("ZZI")
    ZZI->(DbGoTop())
    while ZZI->(!EOF())
        if AllTrim(ZZI_CODIGO) == cCodInst 
            if nOper == 3 
                RecLock("ZZI", .F.)
                    ZZI -> ZZI_QUANTA += 1 
                ZZI->(MsUnlock())

                //? para validar se o instrutor tem ou não 5 alunos
                if ZZI_QUANTA >= 5
                    lRet := .F.
                    lAluMax := .T.
                    Help(Nil, Nil, "Não autorizado!", Nil, "Esse instrutor já tem alunos suficientes", 1, 0, Nil, Nil, Nil, Nil, Nil, {"Espere o instrutor finalizar algumas aulas."})
                endif
            elseif nOper == 5 
                RecLock("ZZI", .F.)
                    ZZI -> ZZI_QUANTA -= 1   
                ZZI->(MsUnlock())
            endif
        endif
        ZZI->(DbSkip())  
    end       

    //? para validação do instrutor não preenchido
    if nOper == 3 
        if Empty(cTemInst) .AND. cTemAula == "Sim" 
            lRet := .F.
            Help(Nil, Nil, "Não autorizado!", Nil, "É necessário selecionar um instrutor", 1, 0, Nil, Nil, Nil, Nil, Nil, {"Informe qual é o seu instrutor."})
        elseif lAluMax .AND. cTemAula == "Sim"
            //? para validar se já tem alunos suficientes o campo tem aula não pode ser sim
            lRet := .F.
            Help(Nil, Nil, "Não autorizado!", Nil, "Esse instrutor já tem aulas suficientes", 1, 0, Nil, Nil, Nil, Nil, Nil, {"Espere ele encerrar as aulas."})
        endif 
    endif

    //? Impede de excluir com a opção 5
    if nOper == 5 .AND. cTemAula == "Sim"
        lRet := .F.
        Help(Nil, Nil, "Não autorizado!", Nil, "Esse aluno ainda está tendo aulas", 1, 0, Nil, Nil, Nil, Nil, Nil, {"Espere o aluno encerrar as aulas."}) 
    endif

Return lRet
